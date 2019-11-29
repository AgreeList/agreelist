require 'spec_helper'

feature 'upvote', js: true do
  before do
    @statement = create(:statement)
    @agreement = create(:agreement, statement: @statement, individual: create(:individual), extent: 100)
  end

  context 'logged user' do
    before do
      visit statement_path(@statement)
    end

    scenario "should change text to upvoted! (1)" do
      click_link "You?"
      click_link "I agree"
      click_link "vote-twitter-login"
      Individual.last.update_attributes(admin: true)
      fill_in "agreement_reason", with: "hmmm..."
      click_button "Save"
      expect(page).not_to have_content("upvoted! (1)")
      expect{ click_upvote }.to change{ Upvote.count }.by(1)
      expect(page).to have_content("upvoted! (1)")
    end

    scenario "should change upvotes_count" do
      click_link "You?"
      click_link "I agree"
      click_link "vote-twitter-login"
      fill_in "agreement_reason", with: "hmmm..."
      click_button "Save"
      before_counter = Agreement.last.upvotes_count
      click_upvote
      after_counter = Agreement.last.upvotes_count
      expect(after_counter).to eq before_counter + 1
    end

    context "when updating twice" do
      scenario "should destroy the upvote" do
        click_link "You?"
        click_link "I agree"
        click_link "vote-twitter-login"
        Individual.last.update_attributes(admin: true)
        fill_in "agreement_reason", with: "hmmm..."
        click_button "Save"
        click_upvote
        expect{ click_link "upvoted! (1)" }.to change{ Upvote.count }.by(-1)
      end
    end
  end

  context 'non logged user' do
    before do
      visit statement_path(@statement)
    end

    context 'sign in with twitter' do
      scenario "upvote" do
        click_link "upvote"
        click_link "upvote-twitter-login"
        expect(page).to have_content("upvoted!")
      end
    end

    context 'sign in with email' do
      scenario "upvote" do
        click_link "upvote"
        click_link "upvote-email-login"
        click_link "Sign up!"
        fill_in :individual_email, with: "whatever@email.com"
        fill_in :individual_password, with: "whatever-password"
        fill_in :individual_password_confirmation, with: "whatever-password"
        click_button "Sign up"
        expect(page).to have_content("Upvoted!")
      end
    end
  end

  private

  def click_upvote
    find(:xpath, "(//a[text()='upvote'])[1]").click
  end
end
