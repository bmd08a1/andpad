class UsersController < ApplicationController
  before_action :require_login

  def create
    contract = RegisterUserContract.new.call(params.to_unsafe_h['user'])

    if contract.success?
      if UsersPolicy.can_create?(current_user)
        register_params = contract.to_h.except(:password_confirmation)
        service = Users::Create.new(**register_params.merge(company_id: current_user.company_id))
        service.call

        if service.success?
          render json: { success: true }
        else
          render json: { success: false, error_messages: service.error_messages }, status: 422
        end
      else
        render json: { success: false, error_messages: ['unauthorized'] }, status: 403
      end
    else
      render json: { success: false, error_messages: contract.errors.to_h }, status: 400
    end
  end
end
