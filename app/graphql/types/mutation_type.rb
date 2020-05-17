Types::MutationType = GraphQL::ObjectType.define do
  name "Mutation"
  field :createStatement, function: Mutations::Statements::CreateStatement
  field :createIndividual, function: Mutations::Individuals::CreateIndividual
end
