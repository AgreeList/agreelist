require 'spec_helper'

feature "reason categories", js: true do
  attr_reader :statement

  before do
    seed_data
  end

  context "non logged user" do
    before do
      login
      visit statement_path(statement)
    end

    scenario "should set a category" do
      select "Economy", from: "reason_category_from_agreement_#{Agreement.last.id}"
      expect(Agreement.last.reason_category.name).to eq "Economy"
    end
  end

  def seed_data
    @statement = create(:statement)
    create(:agreement, statement: @statement, individual: create(:individual), reason: "blablabla", extent: 100)
    ReasonCategory.create(name: "Economy")
    ReasonCategory.create(name: "Science")
  end

  def login
    visit "/auth/twitter"
    Individual.last.update_attributes(admin: true)
  end
end
