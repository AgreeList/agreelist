class Agreement < ActiveRecord::Base
  SHORTENED_REASON_MAX_SIZE = 400
  validates :individual_id, presence:true
  validates :statement_id, presence:true

  belongs_to :statement
  belongs_to :individual
  belongs_to :reason_category, optional: true
  belongs_to :added_by, optional: true, class_name: "Individual"
  has_many :agreement_comments
  has_many :upvotes

  before_create :generate_hashed_id
  after_create :rm_opposite_agreement, :update_counters, :incr_statement_tag_caches, :incr_individual_opinions_count, :incr_statement_opinions_count
  after_destroy :decr_statement_tag_caches, :decr_individual_opinions_count, :decr_statement_opinions_count

  scope :group_by_month, -> { group("date_trunc('month', created_at)") }

  acts_as_list

  def short_url
    url.gsub(/.*http:\/\//,'').gsub(/.*www\./,'')[0..15] + "..."
  end

  def disagree?
    extent == 0
  end

  def agree?
    extent == 100
  end

  def agree_or_disagree?
    agree? ? "agree" : "disagree"
  end

  def to_param
    self.hashed_id
  end

  def self.context(context_name, context_value)
    joins("left join taggings on taggings.taggable_id=agreements.individual_id left join tags on tags.id=taggings.tag_id").
    where(taggings: {taggable_type: "Individual", context: context_name}).
    where("lower(tags.name) = ?", context_value.downcase)
  end

  def self.two_contexts(context_name1, context_value1, context_name2, context_value2)
    context(context_name1, context_value1).
    joins("left join taggings as taggings2 on taggings2.taggable_id=agreements.individual_id left join tags as tags2 on tags2.id=taggings2.tag_id").
    where(taggings2: {taggable_type: "Individual", context: context_name2}).
    where("lower(tags2.name) = ?", context_value2.downcase)
  end

  def self.filter(filters, user = nil)
    if filters[:include] == "opinions and votes"
      agreements = self
    elsif filters[:include] == "opinions" || filters[:include].nil?
      agreements = self.where("reason is not null and reason != ''")
    elsif filters[:include] == "votes"
      agreements = self.where("reason is null or reason = ''")
    end
    if filters[:occupation].present?
      if filters[:school].present?
        agreements = agreements.two_contexts("occupations", filters[:occupation], "schools", filters[:school])
      else
        agreements = agreements.context("occupations", filters[:occupation])
      end
    elsif filters[:school].present?
      agreements = agreements.context("schools", filters[:school])
    end

    agreements = agreements.joins("left join individuals on individuals.id=agreements.individual_id")
    if filters[:type] == "nobel laureates"
      agreements = agreements.where("individuals.nobel_laureate = true")
    elsif filters[:type].nil? || filters[:type] == "influencers"
      agreements = agreements.where("individuals.wikipedia is not null and individuals.wikipedia != ''")
    elsif filters[:type] == "people"
      agreements = agreements.where("individuals.wikipedia is null or individuals.wikipedia = ''")
    elsif filters[:type] == "people I follow" && user.present?
      follow_ids = user.follows_by_type("Individual").map{|f| f.followable_id}
      agreements = agreements.where(individual_id: follow_ids)
    end

    if filters[:statement].present?
      s = Statement.find_by_content(filters[:statement])
      agreements = agreements.where(statement_id: s.id) if s
    end

    if filters[:v].present?
      if filters[:v] == "agree"
        agreements = agreements.where(extent: 100)
      elsif filters[:v] == "disagree"
        agreements = agreements.where(extent: 0)
      end
    end

    if filters[:order].present?
      if filters[:order] == "recent"
        agreements = agreements.order(updated_at: :desc)
      end
    else
      agreements = agreements.order(position: :asc, upvotes_count: :desc)
    end
    agreements
  end

  private

  def update_counters
    if agree?
      statement.agree_counter = statement.agree_counter + 1
    else
      statement.disagree_counter = statement.disagree_counter + 1
    end
    statement.save
  end

  def rm_opposite_agreement
    agreement = Agreement.where(statement: statement, individual: individual, extent: opposite_extent).first
    agreement.destroy if agreement
  end

  def opposite_extent
    extent == 100 ? 0 : 100
  end

  def generate_hashed_id
    self.hashed_id = loop do
      token = SecureRandom.urlsafe_base64.gsub("-", "_")
      break token unless Agreement.where('hashed_id' => token).first.present?
    end
  end

  def incr_statement_tag_caches
    OccupationsCache.new(statement: statement).add(self.individual.occupation_list)
    SchoolsCache.new(statement: statement).add(self.individual.school_list)
  end

  def decr_statement_tag_caches
    OccupationsCache.new(statement: statement).add(self.individual.occupation_list, -1)
    SchoolsCache.new(statement: statement).add(self.individual.school_list, -1)
  end

  def incr_individual_opinions_count
    individual.update_attributes(opinions_count: individual.opinions_count + 1) if self.reason.present?
  end

  def decr_individual_opinions_count
    individual.update_attributes(opinions_count: individual.opinions_count - 1) if self.reason.present?
  end

  def incr_statement_opinions_count
    statement.update_attributes(opinions_count: statement.opinions_count + 1) if self.reason.present?
  end

  def decr_statement_opinions_count
    statement.update_attributes(opinions_count: statement.opinions_count - 1) if self.reason.present?
  end
end
