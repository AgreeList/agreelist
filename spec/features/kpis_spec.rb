require 'spec_helper'

feature 'kpis', js: true do
  before do
    create(:individual)
    visit "/auth/twitter"
    Individual.last.update_attributes(admin: true)
  end

  it "basic individuals_count" do
    create(:individual, email: "my@email.com")
    visit kpis_path
    expect(page).to have_content("- 1")
  end

  it "basic opinions count" do
    create(:agreement, reason: "blabla")
    create(:agreement, reason: "blabla")
    visit kpis_path
    expect(page).to have_content("- 2")
  end
end
