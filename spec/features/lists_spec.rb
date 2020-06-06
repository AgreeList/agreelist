require 'spec_helper'

feature 'lists' do
  before do
    @list1 = List.create(name: 'My list')
    @list2 = List.create(name: 'My other list')
  end

  context '#index' do
    it 'should display lists' do
      visit lists_path
      expect(page).to have_link('My list', href: list_path(@list1))
      expect(page).to have_link('My other list', href: list_path(@list2))
    end
  end

  context '#show' do
    it 'should include statements' do
      statement = @list1.statements.create(content: 'The sky is blue')
      visit lists_path
      click_link 'My list'
      expect(page).to have_content('The sky is blue')
      click_link 'The sky is blue'
      expect(current_path).to eq statement_path(statement)
    end
  end

  context '#create_statement' do
    it 'should create an statement and add it to the list' do
      login_as_admin
      visit list_path(@list1)
      fill_in 'statement_content', with: 'Let\'s go to Mars'
      expect { click_button 'Create' }.to change{ Statement.count }.by(1)
      expect(current_path).to eq list_path(@list1)
      expect(page).to have_link('Let\'s go to Mars', href: statement_path(Statement.last))
    end
  end
end
