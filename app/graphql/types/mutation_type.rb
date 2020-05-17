module Types
  class MutationType < Types::BaseObject
    field :create_statement, mutation: Mutations::Statements::CreateStatement
    field :create_individual, mutation: Mutations::Individuals::CreateIndividual do
      guard ->(obj, args, ctx) { ctx[:user_from_session].present? }
    end
    field :create_event, mutation: Mutations::Events::CreateEvent do
      guard ->(obj, args, ctx) { ctx[:user_from_session].present? }
    end
  end
end
