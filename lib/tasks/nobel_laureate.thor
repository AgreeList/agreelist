class NobelLaureate < Thor
  desc "set",
       "set nobel laureate flag if bio starts with Nobel"
  def set
    require './config/environment'
    nobel_ids = Individual.where("bio like 'Nobel%'").map(&:id)
    Individual.where(id: nobel_ids).update_all(nobel_laureate: true)
  end
end
