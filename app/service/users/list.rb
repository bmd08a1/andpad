module Users
  class List < BaseService
    def initialize(current_user:)
      super()
      @current_user = current_user
    end

    def call
      user_data = get_user_data
      team_data = get_team_data
      member_data = get_member_data

      @data = user_data.keys.map do |user_id|
        {
          user_id: user_id,
          user_name: user_data[user_id][:user_name],
          email: user_data[user_id][:email],
          is_manager: team_data[user_id].present?,
          managed_team: team_data[user_id],
          member_of: member_data[user_id]
        }
      end
    rescue ActiveRecord::ActiveRecordError => e
      add_error(e)
    end

    private

    def get_user_data
      User.where(company_id: @current_user.company_id).pluck(:id, :first_name, :last_name, :email).
        each_with_object({}) do |(id, first_name, last_name, email), result|
          result[id] = { user_name: first_name + ' ' + last_name, email: email }
          result
        end
    end

    def get_team_data
      CompanyStructure::Team.where(company_id: @current_user.company_id).pluck(:id, :name, :manager_id).
        each_with_object({}) do |(team_id, team_name, user_id), result|
          result[user_id] = { team_id: team_id, team_name: team_name }
          result
        end
    end

    def get_member_data
      team_data = CompanyStructure::Team.where(company_id: @current_user.company_id).pluck(:id, :name).
        each_with_object({}) do |(team_id, team_name), result|
          result[team_id] = team_name
          result
        end

      CompanyStructure::Member.where(team_id: team_data.keys).pluck(:team_id, :user_id).
        each_with_object({}) do |(team_id, user_id), result|
          result[user_id] = { team_id: team_id, team_name: team_data[team_id] }
          result
        end
    end
  end
end
