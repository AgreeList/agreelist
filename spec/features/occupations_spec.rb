require 'spec_helper'

feature 'schools#show' do
  before do
    login
    @elon = create(:individual, name: "Elon Musk", twitter: "elonmusk", occupation_list: "A, B, C")
    create(:agreement, individual: @elon, reason: "A carbon tax is the way to go")
  end

  scenario "user profile should link to user profile" do
    visit individual_path(@elon, all: 1)
    click_link "A"
    expect(page).to have_link "Elon Musk"
  end

  scenario "school should have reason" do
    visit individual_path(@elon, all: 1)
    click_link "B"
    expect(page).to have_content "A carbon tax is the way to go"
  end
end
