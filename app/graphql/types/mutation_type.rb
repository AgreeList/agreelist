module Types
  class MutationType < Types::BaseObject
    field :create_statement, mutation: Mutations::Statements::CreateStatement do
      guard ->(obj, args, ctx) { ctx[:current_user].present? }
    end
    field :create_individual, mutation: Mutations::Individuals::CreateIndividual do
      guard ->(obj, args, ctx) { ctx[:current_user].present? }
    end
  end
end
