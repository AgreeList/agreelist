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
      click_link "add more?"
      click_link "donate $100 and we'll find 50 influencers"
      expect(page).to have_content("I'd like to donate $100 so you can help me to find 50 influencers for the topic or statement: #{@statement.content}")
    end
  end

  context "with no opinions" do
    it "button donate should go and fill form" do
      visit statement_path(@statement)
      click_link "Donate $100 and we'll find 50 influencers"
      expect(page).to have_content("I'd like to donate $100 so you can help me to find 50 influencers for the topic or statement: #{@statement.content}")
    end
  end

  def seed_data
    @statement = create(:statement)
    @profession = create(:profession, name: "Economist")
  end
end
