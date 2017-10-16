require 'spec_helper'

feature 'individuals' do
  before do
    create(:individual, name: 'one')
    create(:individual, name: 'two')
    create(:individual, name: 'three')
  end

  scenario 'name' do
    visit "/api/v1?query={individuals{name}}"
    expect(page).to have_content('{"data":{"individuals":[{"name":"one"},{"name":"two"},{"name":"three"}]}}')
  end
end
