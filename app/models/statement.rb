class Statement < ActiveRecord::Base
  MAXIMUM_LENGTH = 500
  acts_as_followable

  has_attached_file :picture, s3_host_name: "s3-eu-west-1.amazonaws.com", :default_url => 'https://s3-eu-west-1.amazonaws.com/agreelist/missing-:style.jpg', s3_protocol: 'https', styles: {
    mini: "50x50#",
    thumb: '100x100#',
    square: '200x200#',
    medium: '300x300>'
  }

  validates_attachment_content_type :picture, :content_type => /\Aimage\/.*\Z/
  validates :content, presence: true, length: { maximum: MAXIMUM_LENGTH }
  validates :description, length: { maximum: 300}

  has_many :agreements, dependent: :destroy
  has_many :individuals, :through => :agreements
  has_many :comments
  belongs_to :individual, optional: true

  acts_as_taggable

  before_create :generate_hashed_id, :set_none_tag
  before_create :set_url, if: :blank_url?
  after_create :follow_topic
  before_update :store_old_url_if_changed


  def to_s
    content
  end

  def agreements_in_favor(args = {})
    filtered_agreements(:agree, args)
  end
  alias_method :supporters, :agreements_in_favor

  def agreements_against(args = {})
    filtered_agreements(:disagree, args)
  end
  alias_method :detractors, :agreements_against

  def supporters_count(args = {})
    filtered_agreements_count(:agree, args)
  end

  def detractors_count(args = {})
    filtered_agreements_count(:disagree, args)
  end

  def to_param
    self.url
  end

  def shortened_content(limit)
    if content_with_abbreviations.size > limit
      content_with_abbreviations[0..(limit-4)] + "..."
    else
      content_with_abbreviations
    end
  end

  def content_with_abbreviations
    content.gsub("Advanced Artificial Intelligence", "AI")
  end

  def tags?
    tag_list != ["none"]
  end

  def brexit?
    id == 7
  end

  def set_url
    self.url = generate_url
  end

  def generate_url
    content.split(" ")[0..9].join("-").gsub(/[^0-9a-z-]/i, '').downcase
  end

  def picture_from_url=(url)
    self.picture = open(url) if url.present?
  end

  def picture_from_url
    ""
  end

  private

  def follow_topic
    individual.follow(self) if individual
  end

  def filtered_agreements_count(agree_or_disagree, args)
    a = agreements.where(extent: (agree_or_disagree == :agree ? 100 : 0)).where("reason is not null and reason != ''")
    a.count
  end

  def tag_joins(a)
    b = a.joins("left outer join individuals on agreements.individual_id = individuals.id")
    b = b.joins("left outer join taggings on taggings.taggable_id = individuals.id")
    b = b.joins("left outer join tags on tags.id = taggings.tag_id")
  end

  def filtered_agreements(agree_or_disagree, args)
    a = agreements.where(extent: (agree_or_disagree == :agree ? 100 : 0)).includes(:individual).includes(:upvotes)
    a = a.where(reason_category_id: args[:category_id]) if args[:category_id]
    a = a.where(reason_category_id: nil) if args[:filter_by] == :non_categorized
    a = a.includes(:agreement_comments)
    if args[:order ] == "date"
      a = a.order("created_at DESC")
    else
      a = a.order("agreements.upvotes_count DESC")
      a = a.order("case when (agreements.reason is not null and agreements.reason != '') THEN 1 END ASC, case when agreements.reason is null THEN 0 END ASC")
      a = a.order("case when individuals.wikipedia is not null THEN 1 END ASC, case when individuals.wikipedia is null THEN 0 END ASC")
      a = a.order("individuals.followers_count DESC")
    end
    a = a.page(args[:page]).per(30)
  end

  def ranking(agreement)
    r = agreement.individual.ranking
    r == 0 ? agreement.individual.followers_count : r
  end

  def generate_hashed_id
    self.hashed_id = loop do
      token = SecureRandom.urlsafe_base64[0,12].downcase.gsub("-", "a").gsub("_", "b")
      break token unless Statement.where('hashed_id' => token).first.present?
    end
  end

  def set_none_tag
    self.tag_list.add("none") unless self.tag_list.any?
  end

  def blank_url?
    self.url.blank?
  end

  def store_old_url_if_changed
    if self.url_changed?
      old_url, new_url = self.changes[:url]
      store_old_url(old_url)
      rm_new_url_from_old_urls_if_it_was_there(new_url)
    end
  end

  def store_old_url(original_url)
    OldStatementUrl.create(statement_id: self.id, url: original_url) unless OldStatementUrl.exists?(statement_id: self.id, url: original_url)
  end

  def rm_new_url_from_old_urls_if_it_was_there(new_url)
    if OldStatementUrl.exists?(url: new_url, statement_id: self.id)
      old = OldStatementUrl.where(url: new_url, statement_id: self.id).first
      old.destroy
    end
  end
end
