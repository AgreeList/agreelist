require "spec_helper"

feature "new" do
  context "logged in" do
    scenario "loads" do
      create(:statement)
      visit "/auth/twitter"
      expect(page).to have_content("+")
    end
  end

  context "non logged in" do
    scenario "loads" do
      create(:statement)
      visit "/"
      expect(page).to have_content("+")
    end
  end
end
