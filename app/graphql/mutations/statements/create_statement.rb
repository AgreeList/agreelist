class Mutations::Statements::CreateStatement < GraphQL::Function
  argument :content, String

  # define what this field will return
  type Types::StatementType

  # resolve the field's response
  def self.call(obj, args, ctx)
    Statement.create!(content: args[:content])
  end
end
