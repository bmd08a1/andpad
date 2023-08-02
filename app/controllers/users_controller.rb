class UsersController < ApplicationController
  def create
    contract = RegisterUserContract.new.call(params.to_unsafe_h['user'])

    if contract.success?
      register_params = contract.to_h.except(:password_confirmation)
      service = Users::Create.new(**register_params)
      service.call

      if service.success?
        render json: { success: true }
      else
        render json: { success: false, error_messages: service.error_messages }, status: 422
      end
    else
      render json: { success: false, error_messages: contract.errors.to_h }, status: 400
    end
  end
end
