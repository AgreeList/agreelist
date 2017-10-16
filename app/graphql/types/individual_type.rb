Types::IndividualType = GraphQL::ObjectType.define do
  name 'Individual'

  field :id, !types.ID
  field :name, types.String
  field :twitter, types.String
  field :wikipedia, types.String
  field :wikidata, types.String
end
