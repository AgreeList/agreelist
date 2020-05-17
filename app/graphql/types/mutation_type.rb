Types::MutationType = GraphQL::ObjectType.define do
  name "Mutation"
  field :createStatement, function: Mutations::Statements::CreateStatement
end
