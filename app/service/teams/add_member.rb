module Teams
  class AddMember < BaseService
    def initialize(team_id:, member_id:)
      super()
      @team_id = team_id
      @member_id = member_id
    end

    def call
      team = CompanyStructure::Team.find(@team_id)

      ActiveRecord::Base.transaction do
        team.add_member(@member_id)
      end
    rescue StandardError => e
      add_error(e)
    end
  end
end
