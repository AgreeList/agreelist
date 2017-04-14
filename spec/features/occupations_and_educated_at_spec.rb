require "spec_helper"

feature "Occupations" do
  before do
    seed_data
  end

  scenario "should list occupations" do
    OccupationsTable.any_instance.stub(:min_count).and_return(1)
    visit occupations_statement_path(@statement)
    expect(page).to have_content("Economist 50% 2 Politician 100% 1 Journalist 0%")
  end

  private

  def seed_data
    @statement = create(:statement)
    add_person(occupations: %w(economist politician), extent: 100)
    add_person(occupations: %w(journalist economist), extent: 0)
  end

  def add_person(args)
    individual = create(:individual)
    Agreement.create(statement: @statement, individual: individual, extent: args[:extent] || 100)
    individual.occupation_list = args[:occupations]
    individual.save
  end
end

feature "Educated at" do
  before do
    seed_data
  end

  scenario "should list universities" do
    SchoolsTable.any_instance.stub(:min_count).and_return(1)
    visit educated_at_statement_path(@statement)
    expect(page).to have_content("Stanford 50% 2 Mit 100% 1 Harvard 0% 1")
  end

  private

  def seed_data
    @statement = create(:statement)
    add_person(educated_at: %w(Stanford MIT), extent: 100)
    add_person(educated_at: %w(Harvard Stanford), extent: 0)
  end

  def add_person(args)
    individual = create(:individual)
    Agreement.create(statement: @statement, individual: individual, extent: args[:extent] || 100)
    individual.school_list = args[:educated_at]
    individual.occupation_list = args[:occupations]
    individual.save
  end
end
