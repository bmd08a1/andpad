module Users
  class GetDetails < BaseService
    def initialize(user_id:)
      @user_id = user_id
    end

    def call
      user = User.find(@user_id)
      managed_team, belonged_team = get_company_structure_data

      @data = OpenStruct.new(id: @user_id, company_id: user.company_id, is_owner: user.is_owner?,
                             is_manager: managed_team.present?, managed_team: managed_team, member_of: belonged_team)
    end

    private

    def get_company_structure_data
      managed_team = CompanyStructure::Team.where(manager_id: @user_id).pluck(:id).last
      belonged_team = CompanyStructure::Member.where(user_id: @user_id).pluck(:team_id).last

      return managed_team, belonged_team
    end
  end
end
