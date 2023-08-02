class TeamsPolicy
  def self.can_create?(current_user, manager_id)
    current_user.is_owner &&
      (current_user.company_id == User.where(id: manager_id).pluck(:company_id).last)
  end

  def self.can_add_member?(current_user, team_id, member_id)
    member_company_id = User.where(id: member_id).pluck(:company_id).last
    team_manager_id, team_company_id = Team.where(id: team_id).pluck(:manager_id, :company_id).last

    (current_user.company_id == member_company_id) &&
      (current_user.company_id == team_company_id) &&
      (current_user.is_owner || (current_user.is_manager && current_user.id == team_manager_id))
  end
end
