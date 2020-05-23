require 'spec_helper'

feature 'voting', js: true do
  attr_reader :statement

  before do
    seed_data
  end

  context 'logged user' do
    it "should add opinion" do
      login
      visit "/#{@individual.to_param}"
      fill_in :content, with: "climate change is real"
      fill_in :reason, with: "most scientists agree"
      fill_in :url, with: "http://whatever.com"
      expect{ click_button "She/he disagrees" }.to change{ Agreement.count }.by(1)
      a = Agreement.last
      expect(a.statement.content).to eq "climate change is real"
      expect(a.reason).to eq "most scientists agree"
      expect(a.url).to eq "http://whatever.com"
      expect(a.extent).to eq 0
    end
  end

  private

  def seed_data
    @statement = create(:statement)
    @individual = create(:individual, twitter: "someone")
    create(:agreement, statement: @statement, individual: @individual, extent: 100)
  end
end
