class Wikidata < Thor
  desc "fetch",
       "fetch wikidata for occupations, educated_at and countries"

  def fetch
    require './config/environment'
    Individual.where("wikidata_id is not null").each do |individual|
      if individual.occupations.empty? || individual.schools.empty? || individual.countries.empty?
        puts "-----------------"
        puts individual.name
        wikidata_person = WikidataPerson.new(wikidata_id: individual.wikidata_id)
        individual.occupation_list = wikidata_person.occupations
        puts "occupations: #{individual.occupation_list.join(', ')}"
        individual.school_list = wikidata_person.educated_at
        puts "educated_at: #{individual.school_list.join(', ')}"
        individual.country_list = wikidata_person.countries
        puts "countries: #{individual.country_list.join(', ')}"
        if (individual.occupation_list + individual.school_list + individual.country_list).any?
          puts individual.save
        end
      else
        puts "skipping #{individual.name}"
      end
    end
  end
end
