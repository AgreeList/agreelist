require 'spec_helper'

feature '#opinions_count' do
  before do
    @statement = create(:statement)
    @individual = create(:individual)
    create(:agreement)
  end

  it "should be increased when adding an opinion" do
    expect{ create(:agreement, individual: @individual, statement: @statement, reason: "blabla") }.to change{ @individual.opinions_count }.by(1)
  end

  it "should NOT be increased when adding a vote" do
    expect{ create(:agreement, individual: @individual, statement: @statement, reason: nil) }.not_to change{ @individual.opinions_count }
  end

  it "should be decreased when removing an opinion" do
    agreement = create(:agreement, individual: @individual, statement: @statement, reason: "blabla")
    count = @individual.opinions_count
    agreement.destroy
    expect(@individual.reload.opinions_count).to eq (count - 1)
  end

  it "should NOT be decreased when removing a vote" do
    agreement = create(:agreement, individual: @individual, statement: @statement, reason: nil)
    expect{ agreement.destroy }.not_to change{ @individual.opinions_count }
  end
end
