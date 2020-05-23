require 'spec_helper'

feature "brexit board" do
  attr_reader :statement

  before do
    seed_data
  end

  context "non logged user" do
    before do
      login
      visit statement_path(statement)
    end

    scenario "should list the categories with votes" do
      visit brexit_board_path
      expect(page).to have_content("Economy")
      expect(page).to have_content("Science")
    end
  end

  def seed_data
    @statement = create(:statement)
    individual = create(:individual)
    individual2 = create(:individual)
    individual3 = create(:individual)
    economy = ReasonCategory.create(name: "Economy")
    science = ReasonCategory.create(name: "Science")
    Agreement.create(individual: individual,
                     statement: @statement,
                     extent: 100,
                     reason: "blablabla",
                     reason_category: economy)
    Agreement.create(individual: individual2,
                     statement: @statement,
                     extent: 100,
                     reason: "blablabla",
                     reason_category: economy)
    Agreement.create(individual: individual3,
                     statement: @statement,
                     extent: 100,
                     reason: "blablabla",
                     reason_category: science)
  end
end
