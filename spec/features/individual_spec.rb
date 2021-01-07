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
      visit "/elonmusk?all=1"
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
end
