require "open-uri"

class Individual < ActiveRecord::Base
  attr_accessor :is_user, :reset_token, :activation_token
  has_secure_password(validations: false)

  nilify_blanks only: [:twitter]
  has_attached_file :picture, s3_host_name: "s3-eu-west-1.amazonaws.com", :default_url => '/assets/missing-:style.jpg', styles: {
    mini: "50x50#",
    thumb: '100x100#',
    square: '200x200#',
    medium: '300x300>'
  }
  has_many :agreements, dependent: :destroy
  has_many :statements, :through => :agreements
  has_many :comments, dependent: :destroy
  has_many :upvotes
  belongs_to :category_id
  belongs_to :profession

  validates_attachment_content_type :picture, :content_type => /\Aimage\/.*\Z/
  validates_uniqueness_of :twitter, allow_nil: true
  validates_confirmation_of :password, if: :password_is_present?
  validates :password, length: { minimum: 6, if: :password_is_present? }

  validates_presence_of :password, on: :create, if: :is_user
  validates_presence_of :email, on: :create, if: :is_user
  validates_uniqueness_of :email, if: :is_user
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, if: :is_user


  before_create :update_followers_count, :generate_hashed_id, :generate_activation_digest
  before_save :update_wikidata_id_and_twitter, if: :wikipedia_changed?
  before_save :update_profile_from_twitter, if: :twitter_changed?
  before_save :downcase_email

  def self.create_with_omniauth(auth)
    create! do |user|
      # user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.twitter = auth["info"]["nickname"].downcase
      user.name = auth["info"]["name"]
      user.email = auth["info"]["email"]
      user.followers_count = auth["extra"]["raw_info"]["followers_count"] unless Rails.env == "test"
    end
  end

  def create_reset_digest
    self.reset_token = Individual.new_token
    update_attribute(:reset_digest,  Individual.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    IndividualMailer.password_reset(self).deliver
  end

  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    IndividualMailer.account_activation(self).deliver
  end

  def update_wikidata_id_and_twitter
    # if Rails.env == "production" && wikipedia.present?
    title = self.wikipedia.gsub(/https:\/\/.*wikipedia.org\/wiki\//, "")
    wikidata = Wikidata::Item.find_by_title(title)
    begin
      self.wikidata_id = wikidata.id
    end

    begin
      tw = wikidata.claims_for_property_id("P2002").first
      self.twitter = tw.mainsnak.value.data_hash.string if tw
    rescue => e
      LogMailer.log_email("error updating twitter @#{self.twitter} from wikidata: #{e.message}; backtrace: #{e.backtrace}").deliver
    end
  end

  def update_profile_from_twitter
    if Rails.env == "production" && twitter.present?
      begin
        user = twitter_client.user(twitter)
        self.name = user.name if self.name.blank?
        # self.name = user.name unless %w(gmc jesusencinar arrola jaime_estevez gusbox martaesteve).include?(twitter)
        self.description = user.description
        self.followers_count = user.followers_count
        url = user.profile_image_url_https(:original)
        self.picture = open(url) if self.update_picture
      rescue => e
        if e.message.scan(/User has been suspended/).any?
          LogMailer.log_email("twitter @#{self.twitter} has been suspended").deliver
        else
          LogMailer.log_email("error updating profile from twitter: #{e.message}; backtrace: #{e.backtrace}").deliver
        end
      end
    end
  end

  def voted?(statement)
    Agreement.where(individual: self, statement: statement).any?
  end

  def self.find_or_create(params)
    self.find_by_email(params[:email]) || self.create(params)
  end

  def self.create_from_twitter_if_possible(params)
    if params[:name][0] == "@"
      self.create(email: params[:email].try(:downcase), twitter: params[:name].gsub("@", ""))
    else
      self.create(email: params[:email].try(:downcase), name: params[:name])
    end
  end

  def agrees
    # agreements.select{ |a| a.extent == 100 && a.statement.tag_list.include?("entrepreneurship") }.map{ |i| i.statement }
    agreements.select{ |a| a.extent == 100 }.map{ |i| i.statement }
  end

  def disagrees
    # agreements.select{ |a| a.extent == 0 && a.statement.tag_list.include?("entrepreneurship") }.map{ |i| i.statement }
    agreements.select{ |a| a.extent == 0 }.map{ |i| i.statement }
  end

  def self.search(search)
    search.blank? ? [] : self.where("content LIKE ?", "%#{search}%")
  end

  def to_param
    twitter.present? ? twitter : "user-#{hashed_id}"
  end

  def in_favor?(statement)
    agreement(statement).where(extent: 100).first.present?
  end

  def against?(statement)
    agreement(statement).where(extent: 0).first.present?
  end

  def picture_from_url=(url)
    self.picture = open(url) if url.present?
  end

  def picture_from_url
    ""
  end

  private

  def update_followers_count
    self.followers_count = 0 if self.followers_count.nil?
  end

  def agreement(statement)
    Agreement.where(statement_id: statement.id).where(individual_id: self.id)
  end

  def twitter_client
    # this was in initializers/twitter.rb but heroku didn't find it
    Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_OAUTH_TOKEN']
      config.access_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
    end
  end

  def generate_hashed_id
    self.hashed_id = loop do
      token = rand(999999999).to_s
      break token unless Individual.where('hashed_id' => token).first.present?
    end
  end

  def downcase_email
    self.email = email.try(:downcase)
  end

  def generate_activation_digest
   self.activation_token  = Individual.new_token
   self.activation_digest = Individual.digest(activation_token)
  end

  def self.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def password_is_present?
    password.present?
  end
end
