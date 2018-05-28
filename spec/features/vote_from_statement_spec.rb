require 'spec_helper'
feature 'voting', js: true do
  before do
    @statement = create(:statement)
    create(:agreement, statement: @statement, individual: create(:individual, twitter: "seed"), extent: 100, reason: "whatever")
    create(:reason_category, name: "Politics")
    create(:profession, name: "Politician")
  end

  context 'logged user' do
    before do
      login
      visit statement_path(@statement)
    end

    scenario "agree" do
      click_link "You?"
      expect{ click_link "I agree" }.to change{ Agreement.count }.by(1)
      fill_in :agreement_reason, with: "because..."
      click_button "Save"
      expect(page).to have_content "because..."
      expect(page).to have_content("Hector Perez")
      expect(page).to have_content("Agree 100%")
    end

    scenario "disagree" do
      click_link "You?"
      expect{ click_link "I disagree" }.to change{ Agreement.count }.by(1)
      fill_in :agreement_reason, with: "because..."
      click_button "Save"
      expect(page).to have_content "because..."
      expect(page).to have_content("Hector Perez")
      expect(page).to have_content("50% Disagree")
    end
  end

  context 'non logged user' do
    before do
      visit statement_path(@statement)
    end

    context "twitter login" do
      scenario "agree" do
        click_link "You?"
        click_link "I agree"
        expect{ click_link "vote-twitter-login" }.to change{ Agreement.count }.by(1)
        fill_in :agreement_reason, with: "because..."
        click_button "Save"
        expect(page).to have_content "because..."
        expect(page).to have_content("Hector Perez")
        expect(page).to have_content("Agree 100%")
        expect(page).to have_content("nfluencers")
      end

      scenario "disagree" do
        click_link "You?"
        click_link "I disagree"
        expect{ click_link "vote-twitter-login" }.to change{ Agreement.count }.by(1)
        fill_in :agreement_reason, with: "because..."
        click_button "Save"
        expect(page).to have_content "because..."
        expect(page).to have_content("Hector Perez")
        expect(page).to have_content("Agree 50%")
      end
    end

    context "email login" do
      before do
        Individual.create(email: "bla@bla.com", password: "blabla", name: "bla")
      end

      scenario "agree" do
        click_link "You?"
        click_link "I agree"
        click_link "Log in with your email"
        fill_in :email, with: "bla@bla.com"
        fill_in :password, with: "blabla"
        expect{ click_button "Log in" }.to change{ Agreement.count }.by(1)
        fill_in :agreement_reason, with: "because..."
        click_button "Save"
        expect(page).to have_content "because..."
        expect(page).to have_content("bla")
        expect(page).to have_content("Agree 100%")
      end

      scenario "disagree" do
        click_link "You?"
        click_link "I disagree"
        click_link "Log in with your email"
        fill_in :email, with: "bla@bla.com"
        fill_in :password, with: "blabla"
        expect{ click_button "Log in" }.to change{ Agreement.count }.by(1)
        fill_in :agreement_reason, with: "because..."
        click_button "Save"
        expect(page).to have_content "because..."
        expect(page).to have_content "because..."
        expect(page).to have_content("bla")
        expect(page).to have_content("Agree 50%")
      end
    end
  end

  private

  def login
    visit "/auth/twitter"
  end
end
