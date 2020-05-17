module Api::V2
  class ApiController < ActionController::Base

    before_action :return_unauthorized, if: -> { current_user&.nil? }

    private

    def current_user
      @current_user ||= Individual.find(session[:user_id]) if session[:user_id]
    end

    def anonymous_id
      session[:anonymous_id]
    end

    def return_unauthorized
      render(status: :unauthorized, json: { errors: ['Wrong or missing API key'] })
    end
  end
end
