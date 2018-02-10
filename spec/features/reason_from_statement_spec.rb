require 'spec_helper'

feature 'reason', js: true do
  before do
    @statement = create(:statement)
    @individual = create(:individual)
 end

  context "as admin" do
    before do
      visit "/auth/twitter"
      Individual.last.update_attributes(admin: true)
      Agreement.create(individual: @individual, statement: @statement, extent: 100)
    end

    scenario 'edit reason as admin' do
      visit statement_path(@statement)
      click_link "Add a reason"
      fill_in :agreement_reason, with: "Because..."
      fill_in :agreement_url, with: "http://..."
      click_button "Save"
      expect(Agreement.last.reason).to eq "Because..."
      expect(Agreement.last.url).to eq "http://..."
    end
  end

  context "as non admin" do
    before do
      @new_user = create(:individual, email: "my@email.com", is_user: true, password: "password", password_confirmation: "password")
      visit '/login'
      fill_in :email, with: "my@email.com"
      fill_in :password, with: "password"
      click_button "Log in"
    end

    scenario "should not allow me to edit the reason from someone else" do
      Agreement.create(individual: @individual, statement: @statement, extent: 100)
      visit statement_path(@statement)
      expect(page).not_to have_link("Add a reason")
    end

    scenario "should allow me to edit the reason of my own agreement" do
      Agreement.create(individual: @new_user, statement: @statement, extent: 100)
      visit statement_path(@statement)
      click_link "Add a reason"
      fill_in :agreement_reason, with: "Because..."
      click_button "Save"
      expect(Agreement.last.reason).to eq "Because..."
    end
  end
end
