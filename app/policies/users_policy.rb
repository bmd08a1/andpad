class UsersPolicy
  def initialize(current_user)
    @current_user = current_user
  end

  def can_create?
    @current_user.is_owner || @current_user.is_manager
  end
end
