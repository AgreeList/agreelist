module Types
  class MutationType < Types::BaseObject
    field :create_statement, mutation: Mutations::Statements::CreateStatement
    field :create_individual, mutation: Mutations::Individuals::CreateIndividual
  end
end
