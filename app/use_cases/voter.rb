class Voter
  attr_accessor :voter
  attr_reader :name, :twitter, :current_user, :profession_id, :wikipedia, :bio, :picture

  def initialize(args)
    @twitter = args[:twitter]
    @name = args[:name]
    @current_user = args[:current_user]
    @profession_id = args[:profession_id]
    @wikipedia = args[:wikipedia].try(:strip)
    @bio = args[:bio]
    @picture = args[:picture]
  end

  def find_or_create!
    voter = find_or_build_voter
    voter.name = name if name.present?
    voter.profession_id = profession_id if profession_id.present?
    voter = set_wikipedia_or_bio_link(voter)
    voter.bio = bio if bio.present?
    voter.picture_from_url = picture if picture.present?
    voter.save!
    voter
  end

  private

  def set_wikipedia_or_bio_link(voter)
    if wikipedia.present?
      if wikipedia.scan(/\Ahttps:\/\/\s+\.wikipedia\.org.*\Z/).any?
        voter.wikipedia = wikipedia
      else
        voter.bio_link = wikipedia
      end
    end
    voter
  end

  def find_or_build_voter
    twitter ? find_or_build_twitter_user : (find_user_on_wikipedia || build_user)
  end

  def build_user
    Individual.new
  end

  def find_twitter_user
    Individual.find_by_twitter(twitter) || Individual.new(twitter: twitter)
  end

  def find_or_build_twitter_user
    Individual.where(twitter: twitter).first || Individual.new(twitter: twitter)
  end

  def find_user_on_wikipedia
    Individual.find_by_wikipedia(wikipedia) if wikipedia.present?
  end
end
