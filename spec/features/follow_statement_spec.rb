require 'spec_helper'

feature "follow_statement", js: true do
  before do
    seed_data
    visit statement_path(@statement)
  end

  context "twitter login" do
    before do
      visit "/auth/twitter"
      Individual.last.update_attributes(admin: true)
    end

    scenario "should change button to following and back again" do
      expect{ click_link "Follow" }.to change{ Follow.count }.by(1)
      expect(page).to have_content "Following"
      expect{ click_link "Following" }.to change{ Follow.count }.by(-1)
      expect(page).to have_content "Follow"
    end

    scenario "should update follows page" do
      click_link "Follow"
      visit follows_path
      expect(page).to have_content(@statement.content)
    end
  end

  context "email login" do
    before do
      Individual.create(email: "bla@bla.com", password: "blabla", name: "bla")
    end

    scenario "should follow" do
      click_link "Follow"

      click_link "Log in with your email"
      fill_in :email, with: "bla@bla.com"
      fill_in :password, with: "blabla"
      click_button "Log in"
      expect(page).to have_content "Following"
    end
  end

  def seed_data
    @statement = create(:statement)
  end
end
