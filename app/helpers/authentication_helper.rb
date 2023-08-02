module AuthenticationHelper
  class UnauthenticatedError < StandardError; end

  def require_login
    raise UnauthenticatedError.new if request.headers['token'].blank?
  end

  def current_user
    @current_user ||=
      begin
        user_id = find_user_by_access_token
        service = Users::GetDetails.new(user_id: user_id)
        service.call

        service.data
      end
  end

  def find_user_by_access_token
    access_token = request.headers['token']
    user_id = Authentication::AccessToken.not_expired.where(token: access_token).pluck(:user_id).last

    if user_id.present?
      return user_id
    else
      raise UnauthenticatedError.new
    end
  end
end
