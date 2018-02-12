require 'spec_helper'

feature 'add opinion from influencer', js: true do
  attr_reader :statement

  before do
    seed_data
  end

  context 'logged user' do
    before do
      login
      visit statement_path(statement)
    end

    scenario 'adds reason category' do
      fill_in 'name', with: "Cesar Perez"
      click_button "Add opinion"
      select "Politics", from: "reason_category_id"
      click_button "She/he agrees"
      expect(Agreement.last.reason_category.name).to eq "Politics"
    end

    scenario 'adds profession' do
      fill_in 'name', with: "Cesar Perez"
      click_button "Add opinion"
      select "Politician", from: "profession_id"
      click_button "She/he agrees"
      expect(Agreement.last.individual.profession.name).to eq "Politician"
    end


    scenario 'should open share on twitter modal window' do
      fill_in 'name', with: "Barack Obama"
      click_button "Add opinion"
      fill_in 'twitter', with: "barackobama"
      click_button "She/he agrees"
      expect(page).to have_content "Wanna tweet you added @barackobama?"
    end

    scenario 'adds someone who disagrees' do
      fill_in 'name', with: 'Hector Perez'
      click_button "Add opinion"
      click_button "She/he disagree"
      expect(Agreement.last.disagree?).to eq(true)
    end

    scenario 'adds someone who disagrees with its twitter username' do
      fill_in 'name', with: "Hector Perez"
      click_button "Add opinion"
      fill_in 'twitter', with: "@arpahector"
      click_button "She/he disagree"
      expect(Individual.last.twitter).to eq "arpahector"
    end

    scenario 'adds someone who disagrees with its twitter url' do
      fill_in 'name', with: "Hector Perez"
      click_button "Add opinion"
      fill_in 'twitter', with: "https://twitter.com/arpahector"
      click_button "She/he disagree"
      expect(Individual.last.twitter).to eq "arpahector"
    end
  end

  context 'non logged user' do
    before do
      visit statement_path(statement)
      click_link "add opinions"
    end

    scenario 'adds someone who disagrees' do
      fill_in 'name', with: 'Hector Perez'
      click_button "Add opinion"
      click_button "She/he disagree"
      expect(Agreement.last.disagree?).to eq(true)
    end

    scenario 'comment' do
      fill_in 'name', with: 'Hector Perez'
      fill_in 'opinion', with: 'Because...'
      click_button "Add opinion"
      click_button "She/he disagree"
      expect(Agreement.last.reason).to eq "Because..."
    end

    scenario 'bio' do
      fill_in 'name', with: "Barack Obama"
      fill_in 'opinion', with: "My opinion is..."
      click_button "Add opinion"
      fill_in 'biography', with: "bla"
      expect{ click_button "She/he agrees" }.to change{ Agreement.count }.by(1)
      click_link "back"
      expect(page).to have_text("Barack Obama")
      expect(page).to have_text('bla')
    end

    scenario 'should create two users when adding someone else' do
      fill_in 'name', with: 'Hector Perez'
      click_button "Add opinion"
      fill_in 'source', with: 'http://...'
      fill_in 'email', with: 'hhh@jjj.com'
      expect{ click_button "She/he agrees" }.to change{ Individual.count }.by(2)
    end

    scenario 'adds someone who disagrees with its twitter username' do
      fill_in 'name', with: "Hector Perez"
      click_button "Add opinion"
      fill_in 'twitter', with: "arpahector"
      click_button "She/he disagree"
      expect(Individual.last.twitter).to eq "arpahector"
    end

    scenario 'adds someone who disagrees with @ + its twitter username' do
      fill_in 'name', with: "Hector Perez"
      click_button "Add opinion"
      fill_in 'twitter', with: "@arpahector"
      click_button "She/he disagree"
      expect(Individual.last.twitter).to eq "arpahector"
    end

    scenario 'adds two times the same @user' do
      fill_in 'name', with: "Hector Perez"
      click_button "Add opinion"
      fill_in 'twitter', with: "@arpahector"
      click_button "She/he agrees"
      click_link "Back" # modal window asking to twit
      fill_in 'name', with: "Hector Perez"
      click_button "Add opinion"
      click_button "She/he agrees"
      expect(Individual.all.order(:twitter).map(&:twitter)).to eq %w(arpahector whatever_seed)
    end

  end

  private

  def seed_data
    @statement = create(:statement)
    create(:agreement, statement: @statement, individual: create(:individual, twitter: "whatever_seed"), extent: 100)
    create(:reason_category, name: "Politics")
    create(:profession, name: "Politician")
  end

  def login
    visit "/auth/twitter"
  end
end

