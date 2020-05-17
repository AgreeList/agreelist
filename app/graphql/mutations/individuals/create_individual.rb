class Mutations::Individuals::CreateIndividual < GraphQL::Function
  description "Create individual"
  argument :email, !types.String

  # define what this field will return
  type Types::IndividualType

  # resolve the field's response
  def self.call(obj, args, ctx)
    # if ctx[:user_from_context].nil?
    #   raise GraphQL::ExecutionError,
    #           "You need to authenticate to perform this action"
    # end
    Individual.create!(email: args[:email])
  end
end
