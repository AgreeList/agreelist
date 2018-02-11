require 'spec_helper'

feature 'statement' do
  attr_reader :statement

  before do
    seed_data
    visit root_path
  end

  scenario "new issue or statement" do
    click_link "+"
    within ".container" do
      click_link "twitter-login"
    end
    fill_in :statement_content, with: "We should do more to tackle global warming"
    click_button "Create"
    expect(page).to have_content("Statement was successfully created")
  end

  scenario "should add description" do
    click_link "Sign in"
    click_link "twitter-login"
    Individual.last.update_attributes(admin: true)
    visit edit_statement_path(@statement)
    fill_in :statement_description, with: "My description"
    click_button "Update"
    visit statement_path(@statement)
    expect(page).to have_content("My description")
  end

  def seed_data
    @statement = create(:statement)
  end
end
