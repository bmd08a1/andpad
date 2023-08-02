class TeamsPolicy
  def self.can_create?(current_user, manager_id)
    current_user.is_owner &&
      (current_user.company_id == User.where(id: manager_id).pluck(:company_id).last)
  end
end
