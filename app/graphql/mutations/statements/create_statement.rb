class Mutations::Statements::CreateStatement < GraphQL::Function
  description "test mutation - it will be implemented after API authentication"
  argument :content, !types.String

  # define what this field will return
  type Types::StatementType

  # resolve the field's response
  def self.call(obj, args, ctx)
    Statement.create!(content: args[:content])
  end
end
