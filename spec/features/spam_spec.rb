require 'spec_helper'

feature 'spam filter' do
  let(:statement) { create(:statement) }
  let(:individual) { create(:individual) }

  before do
    create(:agreement, statement: statement, extent: 100)
  end

  scenario 'should filter names without surname' do
    # real people tend to have name and surname separated by a space
    visit statement_path(statement)
    fill_in 'name', with: "Spammer"
    fill_in 'opinion', with: "whatever"
    click_button "Add opinion"
    click_button "She/he agrees"
    expect(page).to have_text "Your message has to be approved because it seemed spam."
  end
end
