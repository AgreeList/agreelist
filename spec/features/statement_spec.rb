require 'spec_helper'

feature 'statement' do
  attr_reader :statement

  before do
    seed_data
  end

  scenario "filter per profession" do
    create(:agreement, statement: @statement, individual: create(:individual), extent: 100)
    create(:agreement, statement: @statement, individual: create(:individual, profession: @profession), extent: 100)
    visit statement_path(@statement) + "?profession=#{@profession.name}"
    expect(page).to have_content("100%")
    expect(page).to have_content("1 influencer")
  end

  scenario "new issue or statement" do
    visit root_path
    click_link "+"
    within ".container" do
      click_link "twitter-login"
    end
    fill_in :statement_content, with: "We should do more to tackle global warming"
    click_button "Create"
    expect(page).to have_content("Statement was successfully created")
  end

  def seed_data
    @statement = create(:statement)
    @profession = create(:profession, name: "Economist")
  end
end
