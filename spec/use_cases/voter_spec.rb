require "rails_helper"

describe Voter do
  it "find user by wikipedia link" do
    VCR.use_cassette("use_cases/wikidata/yunus", record: :once) do
      create(:individual, wikipedia: "https://en.wikipedia.org/Muhammad_Yunus")
    end
    voter = Voter.new(name: "Superman", current_user: create(:individual), wikipedia: "https://en.wikipedia.org/Muhammad_Yunus")
    expect{voter.find_or_create!}.not_to change{Individual.count}
  end

  it "should set bio_link instead of wikipedia if it's not a link to wikipedia" do
    voter = Voter.new(name: "Superman", current_user: create(:individual), wikipedia: "https://bio-not-wikipedia.org")
    voter.find_or_create!
    expect(Individual.last.wikipedia).to eq nil
    expect(Individual.last.bio_link).to eq "https://bio-not-wikipedia.org"
  end

  it "find user by twitter username" do
    create(:individual, twitter: "barackobama")
    voter = Voter.new(name: "Obama", current_user: create(:individual), twitter: "barackobama")
    expect{voter.find_or_create!}.not_to change{Individual.count}
  end

  it "find user by name" do
    create(:individual, name: "Barack Obama")
    voter = Voter.new(name: "Obama", current_user: create(:individual), name: "Barack Obama")
    expect{voter.find_or_create!}.not_to change{Individual.count}
  end
end
