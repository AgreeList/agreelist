module Types
  class EventType < Types::BaseObject
    field :name, String, null: false do
      guard ->(obj, args, ctx) { ctx[:user_from_session].present? }
    end
  end
end
