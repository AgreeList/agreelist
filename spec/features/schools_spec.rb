require 'spec_helper'

feature 'schools#show' do
  before do
    login
    @elon = create(:individual, name: "Elon Musk", twitter: "elonmusk", school_list: "A, B, C")
    create(:agreement, individual: @elon, reason: "We must go to Mars")
  end

  scenario "user profile should link to user profile" do
    visit individual_path(@elon, all: 1)
    click_link "A"
    expect(page).to have_link "Elon Musk"
  end

  scenario "school should have reason" do
    visit individual_path(@elon, all: 1)
    click_link "B"
    expect(page).to have_content "We must go to Mars"
  end
end
