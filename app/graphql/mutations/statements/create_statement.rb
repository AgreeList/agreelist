module Mutations
  class Statements::CreateStatement < ::Mutations::BaseMutation
    argument :content, String, required: true

    # define what this field will return
    type Types::StatementType

    # resolve the field's response
    def resolve(content:)
      Statement.create!(content: content)
    end
  end
end
