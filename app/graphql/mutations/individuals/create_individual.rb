class Mutations::Individuals::CreateIndividual < ::Mutations::BaseMutation
  argument :email, String, required: true

  # define what this field will return
  type Types::IndividualType

  # resolve the field's response
  def resolve(email:, **attributes)
    # if ctx[:user_from_context].nil?
    #   raise GraphQL::ExecutionError,
    #           "You need to authenticate to perform this action"
    # end
    Individual.create!(email: email)
  end
end
