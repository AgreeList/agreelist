require 'spec_helper'

feature 'see more', js: true do
  before do
    seed_data
  end

  scenario "should have a shortened reason" do
    visit statement_path(@statement)
    shortened_reason = "aaaa "*(Agreement::SHORTENED_REASON_MAX_SIZE / 5)
    expect(page).to have_content("#{shortened_reason}...")
    expect(page).not_to have_content("aaaa "*250)
  end

  scenario "should display full reason after clicking on See More" do
    visit statement_path(@statement)
    click_link "See More"
    expect(page).to have_content(("aaaa "*250).strip)
  end

  def seed_data
    @statement = create(:statement)
    create(:agreement, statement: @statement, individual: create(:individual), reason: "aaaa "*250, extent: 100)
  end
end
