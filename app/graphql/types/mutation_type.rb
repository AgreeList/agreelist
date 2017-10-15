Types::MutationType = GraphQL::ObjectType.define do
  name "Mutation"
  field :statementCreator, function: Mutations::StatementMutation.new
end
