class CompaniesController < ApplicationController
  def create
    contract = RegisterCompanyContract.new.call(params.to_unsafe_h)

    if contract.success?
      service = Companies::Create.new(**contract.to_h[:company])
      service.call

      if service.success?
        render json: { success: true, data: service.data }
      else
        render json: { success: false, error_messages: service.error_messages }, status: 422
      end
    else
      render json: { success: false, error_messages: contract.errors.to_h }, status: 400
    end
  end
end
