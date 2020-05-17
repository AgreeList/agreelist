module Types
  class IndividualType < Types::BaseObject
    field :id, Integer, null: false
    field :name, String, null: true
    field :twitter, String, null: true
    field :wikipedia, String, null: true
    field :wikidata, String, null: true
    field :email, String, null: true do
      guard ->(obj, args, ctx) { ctx[:user_from_session].present? }
    end
  end
end
