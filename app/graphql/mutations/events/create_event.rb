module Mutations
  class Events::CreateEvent < ::Mutations::BaseMutation
    argument :name, String, required: true

    # define what this field will return
    type Types::EventType

    # resolve the field's response
    def resolve(name:)
      Rails.logger.info "event name: #{name}"
      {"name" => name}
    end
  end
end
