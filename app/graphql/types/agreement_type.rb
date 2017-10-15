Types::AgreementType = GraphQL::ObjectType.define do
  name 'Agreement'

  field :id, !types.ID
  field :reason, types.String
  field :extent, !types.Int
  field :url, types.String
  field :statement, Types::StatementType do
    resolve -> (obj, args, ctx) { obj.statement }
  end
  field :individual, Types::IndividualType do
    resolve -> (obj, args, ctx) { obj.individual }
  end
end
