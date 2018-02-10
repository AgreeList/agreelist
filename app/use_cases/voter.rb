class Voter
  attr_accessor :voter
  attr_reader :name, :twitter, :current_user, :profession_id, :wikipedia, :bio_link, :bio, :picture

  def initialize(args)
    @name = args[:name].try(:strip)
    @twitter = args[:twitter].try(:strip)
    @current_user = args[:current_user]
    @profession_id = args[:profession_id]
    @wikipedia = args[:wikipedia].try(:strip)
    if @wikipedia.present?
      if @wikipedia.scan(/\Ahttps:\/\/\w+\.wikipedia\.org.*\Z/).empty?
        @bio_link = @wikipedia
        @wikipedia = nil
      end
    end
    @bio = args[:bio]
    @picture = args[:picture]
  end

  def find_or_create!
    voter = find_or_build_voter
    voter.name = name if name.present?
    voter.twitter = twitter.gsub(/\Ahttps:\/\/twitter.com\//, '').gsub(/\A\@/, '') if twitter.present?
    voter.wikipedia = wikipedia if wikipedia.present?
    voter.bio_link = bio_link if bio_link.present?
    voter.profession_id = profession_id if profession_id.present?
    voter.bio = bio if bio.present?
    voter.picture_from_url = picture if picture.present?
    voter.save!
    voter
  end

  private

  def find_or_build_voter
    find_by_twitter || find_by_wikipedia || find_by_name || Individual.new
  end

  def find_by_twitter
    Individual.find_by_twitter(twitter) if twitter.present?
  end

  def find_by_wikipedia
    Individual.find_by_wikipedia(wikipedia) if wikipedia.present?
  end

  def find_by_name
    Individual.find_by_name(name) if name.present?
  end
end
