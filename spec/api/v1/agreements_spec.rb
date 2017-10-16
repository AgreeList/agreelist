require 'spec_helper'

feature 'agreements' do
  before do
    create(:agreement, extent: 100, reason: 'one')
    create(:agreement, extent: 100, reason: 'two')
    create(:agreement, extent: 100, reason: 'three')
  end

  scenario 'content' do
    visit "/api/v1?query={agreements{reason}}"
    expect(page).to have_content('{"data":{"agreements":[{"reason":"one"},{"reason":"two"},{"reason":"three"}]}}')
  end
end
