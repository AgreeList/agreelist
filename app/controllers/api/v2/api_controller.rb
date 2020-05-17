# Internal API. Requires a session.
module Api::V2
  class ApiController < ActionController::Base
    protect_from_forgery
    before_action :authenticate

    private

    def authenticate
      return_unauthorized if current_user.nil? && anonymous_id.nil?
    end

    def current_user
      @current_user ||= Individual.find(session[:user_id]) if session[:user_id]
    end

    def anonymous_id
      session[:anonymous_id]
    end

    def return_unauthorized
      head :unauthorized
    end
  end
end
