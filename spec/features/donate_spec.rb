require 'spec_helper'

feature 'donations' do
  attr_reader :statement

  before do
    seed_data
  end

  context "with opinions" do
    before do
      create(:agreement, statement: statement, extent: 100)
    end

    scenario "button donate should go and fill form" do
      visit statement_path(@statement)
      click_link "donate £50 and we'll find 30 influencers on the topic you choose"
    end
  end

  context "with no opinions" do
    it "button donate should go and fill form" do
      visit statement_path(@statement)
      click_link "donate £50 and we'll find 30 influencers on the topic you choose"
    end
  end

  def seed_data
    @statement = create(:statement)
    @profession = create(:profession, name: "Economist")
  end
end
