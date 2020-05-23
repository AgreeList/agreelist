require 'spec_helper'

feature 'individual page', js: true do
  context 'create statement from individual profile' do
    before do
      login
      i = create(:individual, name: "Elon Musk", twitter: "elonmusk")
      s = create(:statement, individual: i)
      visit "/auth/twitter"
      @hector = Individual.find_by_twitter("arpahector")
      create(:agreement, statement: s, individual: i, extent: 100, added_by_id: @hector.id)
    end

    scenario "should add the creator" do
      visit "/elonmusk"
      fill_in :content, with: "We should go to Mars"
      click_button "She/he agrees"
      expect(Statement.last.individual.name).to eq "Hector Perez"
    end

    context "non-existent individual" do
      scenario "should return an error page" do
        visit "/non-existent-page"
        expect(page).to have_content("Agreelist does not have a page for non-existent-page")
      end
    end
  end

  context "game" do
    before do
      i = create(:individual, name: "Neil Armstrong", twitter: "neil")
      @s1 = create(:statement, content: "The sky is blue")
      @s2 = create(:statement, content: "Mars is red")
      @s3 = create(:statement, content: "The Moon is yellow")
      create(:agreement, statement: @s1, individual: i, extent: 100)
      create(:agreement, statement: @s2, individual: i, extent: 100)
      create(:agreement, statement: @s3, individual: i, extent: 100)
    end

    scenario "should ask for email when there are no more questions" do
      allow_any_instance_of(ActionController::Base).to receive(:protect_against_forgery?).and_return(true)
      visit "/neil"
      click_button "Agree"
      expect(page).to have_content("Neil Armstrong agrees:")
      click_button "Next question"
      click_button "Agree"
      click_button "Next question"
      click_button "Agree"
      click_button "Next question"
      fill_in :email, with: "hec7@hec.com"
      expect { click_button "Sign up and save progress" }.to change { Individual.count }.by(1)
      expect(page).to have_content("The sky is blue")
      expect(page).to have_content("Mars is red")
      expect(page).to have_content("The Moon is yellow")
      expect(Individual.last.email).to eq "hec7@hec.com"
      expect(Individual.last.agreements.pluck(:statement_id).sort).to eq [@s1.id, @s2.id, @s3.id].sort
    end
  end
end
