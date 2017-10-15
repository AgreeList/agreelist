class Mutations::StatementMutation < GraphQL::Function
  description "test mutation - it will be implemented after API authentication"
  argument :content, !types.String

  # define what this field will return
  type Types::StatementType

  # resolve the field's response
  def call(obj, args, ctx)
    Statement.new(content: args[:content])
  end
end
