class UsersPolicy
  def self.can_create?(current_user)
    current_user.is_owner || current_user.is_manager
  end
end
