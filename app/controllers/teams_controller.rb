class TeamsController < ApplicationController
  before_action :require_login

  def create
    contract = CreateTeamContract.new.call(params.to_unsafe_h['team'])

    if contract.success?
      if TeamsPolicy.can_create?(current_user, contract.to_h[:manager_id])
        team = CompanyStructure::Team.create(**contract.to_h)

        if team.persisted?
          render json: { success: true }
        else
          render json: { success: false, error_messages: team.errors.messages }, status: 422
        end
      else
        render json: { success: false, error_messages: ['unauthorized'] }, status: 403
      end
    else
      render json: { success: false, error_messages: contract.errors.to_h }, status: 400
    end
  end

  def index
    service = Teams::List.new(current_user: current_user)
    service.call

    if service.success?
      render json: { success: true, data: service.data }
    else
      render json: { success: false, error_messages: service.error_messages }, status: 422
    end
  end
end
