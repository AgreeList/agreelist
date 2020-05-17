class GraphqlController < ApplicationController
  before_action :return_unauthorized, if: -> { current_user.nil? && anonymous_id.nil? }

  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user: current_user,
      user_from_session: user_from_session
    }
    result = AlSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  end

  private

  def return_unauthorized
    head :unauthorized
  end

  def current_user
    @current_user ||= (user_from_session || user_from_api_key)
  end

  def user_from_api_key
    api_key = request.headers['Authorization']
    Individual.find_by(api_key: api_key) if api_key.present?
  end

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end
end
