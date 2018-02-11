require 'spec_helper'

feature 'statement' do
  attr_reader :statement

  before do
    seed_data
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
