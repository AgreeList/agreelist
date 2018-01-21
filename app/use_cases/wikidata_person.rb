class WikidataPerson
  attr_reader :wikidata_id
  PROPERTIES = {
    educated_at: "P69",
    occupations: "P106",
    part_of: "P361",
    countries: "P27"
  }

  def initialize(args)
    @wikidata_id = args[:wikidata_id]
  end

  def fetch(property)
    Wikidata::Item.find_by_id(wikidata_id).claims_for_property_id(property)
  end

  def occupations
    fetch(PROPERTIES[:occupations]).map{|occupation| id(occupation).label}
  end

  def countries
    fetch(PROPERTIES[:countries]).map{|country| id(country).label}
  end

  def educated_at
    educated_at_original + educated_at_extra
  end

  def educated_at_original
    fetch(PROPERTIES[:educated_at]).map{|school| id(school).label}
  end

  def educated_at_extra
    # If educated_at_original returns Harvard Law School, educated_at_extra returns Harvard School
    fetch(PROPERTIES[:educated_at]).map do |i|
      part_of = id(i).claims_for_property_id(PROPERTIES[:part_of])
      part_of.map{|j| id(j).label } if part_of
    end.flatten.compact
  end

  private

  def id(i)
    Wikidata::Item.find_by_id(i.mainsnak.datavalue.value.id)
  end
end
