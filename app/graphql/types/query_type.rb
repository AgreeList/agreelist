module Types
  class QueryType < Types::BaseObject
    field :statements, [Types::StatementType], null: false do
      description "Topic or statement which can be agreed or disagreed"
      argument :limit, Integer, required: false, default_value: 10, prepare: -> (limit, ctx) { [limit, 100].min }
      argument :after, Integer, required: false, default_value: 0
    end

    field :agreements, [Types::AgreementType], null: false do
      description "Votes from individuals and organizations on statements or topics; extent=100 (agree), extent=0 (disagree)"
      argument :limit, Integer, required: false, default_value: 10, prepare: -> (limit, ctx) { [limit, 100].min }
      argument :after, Integer, required: false, default_value: 0
    end

    field :individuals, [Types::IndividualType], null: false do
      description "Person or organization who agrees or disagrees"
      argument :limit, Integer, required: false, default_value: 10, prepare: -> (limit, ctx) { [limit, 100].min }
      argument :after, Integer, required: false, default_value: 0
    end

    def statements(limit:, after:)
      Statement.limit(limit).where("id > ?", after)
    end

    def individuals(limit:, after:)
      Individual.limit(limit).where("id > ?", after)
    end

    def agreements(limit:, after:)
      Agreement.limit(limit).where("id > ?", after)
    end
  end
end
