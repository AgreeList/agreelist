module Types
  class QueryType < Types::BaseObject
    field :statements, [Types::StatementType], null: false do
      description "Topic or statement which can be agreed or disagreed"
    end

    field :agreements, [Types::AgreementType], null: false do
      description "Votes from individuals and organizations on statements or topics; extent=100 (agree), extent=0 (disagree)"
    end

    field :individuals, [Types::IndividualType], null: false do
      description "Person or organization who agrees or disagrees"
    end

    def statements
      Statement.limit(10)
    end

    def individuals
      Individual.limit(10)
    end

    def agreements
      Agreement.limit(10)
    end
  end
end
