class ApplicationController < ActionController::API
  include AuthenticationHelper

  rescue_from UnauthenticatedError, with: :unauthenticated_handler

  def unauthenticated_handler
    render json: { error_messages: ['Unauthenticated'] }, status: 401
  end
end
