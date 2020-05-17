module Mutations
  class Individuals::CreateIndividual < ::Mutations::BaseMutation
    argument :email, String, required: true

    # define what this field will return
    type Types::IndividualType

    # resolve the field's response
    def resolve(email:)
      Individual.create!(email: email)
    end
  end
end
