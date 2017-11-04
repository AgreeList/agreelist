Types::QueryType = GraphQL::ObjectType.define do
  name "Query"

  def field_template(field_name, class_name, type_class, desc)
    field field_name, types[type_class] do
      description desc
      argument :limit, types.Int, default_value: 10, prepare: -> (limit) { [limit, 100].min }
      argument :after, types.Int, default_value: 1, prepare: -> (after) { after }
      resolve ->(obj, args, ctx) {
        class_name.where(["id > ?", args[:after]]).order(id: :asc).limit(args[:limit])
      }
    end
  end

  field_template(:agreements, Agreement, Types::AgreementType, "Votes from individuals and organizations on statements or topics; extent=100 (agree), extent=0 (disagree)")
  field_template(:statements, Statement, Types::StatementType, "Topic or statement which can be agreed or disagreed")
  field_template(:individuals, Individual, Types::IndividualType, "Person or organization who agrees or disagrees")
end
