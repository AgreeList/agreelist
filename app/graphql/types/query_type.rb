Types::QueryType = GraphQL::ObjectType.define do
  name "Query"

  field :agreements, types[Types::AgreementType] do
    description "Votes from individuals and organizations on statements or topics; extent=100 (agree), extent=0 (disagree)"
    argument :limit, types.Int, default_value: 10, prepare: -> (limit) { [limit, 100].min }
    argument :after, types.Int, default_value: 1, prepare: -> (after) { after }
    resolve ->(obj, args, ctx) {
      Agreement.where(["id > ?", args[:after]]).order(id: :asc).limit(args[:limit])
    }
  end

  field :statements, types[Types::StatementType] do
    description "Topic or statement which can be agreed or disagreed"
    argument :limit, types.Int, default_value: 10, prepare: -> (limit) { [limit, 100].min }
    argument :after, types.Int, default_value: 1, prepare: -> (after) { after }
    resolve ->(obj, args, ctx) {
      Statement.where(["id > ?", args[:after]]).order(id: :asc).limit(args[:limit])
    }
  end

  field :individuals, types[Types::IndividualType] do
    argument :limit, types.Int, default_value: 10, prepare: -> (limit) { [limit, 100].min }
    argument :after, types.Int, default_value: 1, prepare: -> (after) { after }
    description "Person or organization who agrees or disagrees"
    resolve ->(obj, args, ctx) {
      Individual.where(["id > ?", args[:after]]).order(id: :asc).limit(args[:limit])
    }
  end
end
