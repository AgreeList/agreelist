require 'spec_helper'

feature 'create statement from individual profile' do
  before do
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

  scenario "should add the creator" do
    visit "/elonmusk"
    fill_in :content, with: "We should go to Mars"
    click_button "She/he agrees"
    expect(page).to have_content("We should go to Mars")
  end

  scenario "should show user's karma if user has email" do
    @hector.update_attributes(email: "bla@bla.com")
    visit "/#{@hector.to_param}"
    expect(page).to have_content("Karma: #{@hector.karma}")
  end

  context "non-existent individual" do
    scenario "should return an error page" do
      visit "/non-existent-page"
      expect(page).to have_content("Agreelist does not have a page for non-existent-page")
    end
  end
end
