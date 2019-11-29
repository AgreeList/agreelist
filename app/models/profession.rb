# Deprecated. This was used for Brexit board - not deleted in case we want to use the data
# Currently we use occupations provided by Wikidata
class Profession < ActiveRecord::Base
  has_many :individuals, dependent: :nullify
end
