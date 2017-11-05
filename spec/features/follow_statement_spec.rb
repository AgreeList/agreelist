require 'spec_helper'

feature "follow_statement", js: true do
  before do
    seed_data
    login
  end

  scenario "should change button to following and back again" do
    visit statement_path(@statement)
    expect{ click_link "Follow" }.to change{ Follow.count }.by(1)
    expect(page).to have_content "Following"
    expect{ click_link "Following" }.to change{ Follow.count }.by(-1)
    expect(page).to have_content "Follow"
  end

  scenario "should update follows page" do
    visit statement_path(@statement)
    click_link "Follow"
    visit follows_path
    expect(page).to have_content(@statement.content)
  end

  def seed_data
    @statement = create(:statement)
  end

  def login
    visit "/auth/twitter"
  end
end
