Types::StatementType = GraphQL::ObjectType.define do
  name 'Statement'

  field :id, !types.ID
  field :content, !types.String
end
