module Types
  class AgreementType < Types::BaseObject
    field :id, Integer, null: false
    field :reason, String, null: true
    field :extent, Integer, null: false
    field :url, String, null: true
    field :statement, Types::StatementType, null: false
    field :individual, Types::IndividualType, null: false
  end
end
