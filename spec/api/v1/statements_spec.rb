require 'spec_helper'

feature 'statements' do
  before do
    create(:statement, content: 'one')
    create(:statement, content: 'two')
    create(:statement, content: 'three')
  end

  scenario 'content' do
    visit "/api/v1?query={statements{content}}"
    expect(page).to have_content('{"data":{"statements":[{"content":"one"},{"content":"two"},{"content":"three"}]}}')
  end
end
