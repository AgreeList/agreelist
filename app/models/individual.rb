class Individual < ActiveRecord::Base
  has_attached_file :picture, s3_host_name: "s3-eu-west-1.amazonaws.com", :default_url => '/assets/missing-:style.jpg', styles: {
    thumb: '100x100#',
    square: '200x200#',
    medium: '300x300>'
  }
  has_many :agreements, dependent: :destroy
  has_many :statements, :through => :agreements

  validates :twitter, :presence => true
  validates_attachment_content_type :picture, :content_type => /\Aimage\/.*\Z/

  before_save :update_profile_from_twitter

  def self.create_with_omniauth(auth)
    create! do |user|
      # user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.twitter = auth["info"]["nickname"].downcase
      user.name = auth["info"]["name"]
      user.followers_count = auth["extra"]["raw_info"]["followers_count"]
    end
  end

  def update_profile_from_twitter
    if Rails.env == "production" && twitter.present?
      user = twitter_client.user(twitter)
      self.name = user.name if twitter != "gmc"
      self.description = user.description
      url = user.profile_image_url_https(:original)
      self.picture = open(url)
    end
  end

  def self.find_or_create(twitter)
    self.find_by_twitter(twitter.downcase) || self.create(twitter: twitter.downcase)
  end

  def agrees
    agreements.select{ |a| a.extent == 100 }.map{ |i| i.statement }
  end

  def disagrees
    agreements.select{ |a| a.extent == 0 }.map{ |i| i.statement }
  end

  def self.search(search)
    search.blank? ? [] : self.where("content LIKE ?", "%#{search}%")
  end

  def to_param
    twitter
  end

  def in_favor?(statement)
    agreement(statement).where(extent: 100).first.present?
  end

  def against?(statement)
    agreement(statement).where(extent: 0).first.present?
  end

  private

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
end
