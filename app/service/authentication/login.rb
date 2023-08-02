module Authentication
  class Login < BaseService
    def initialize(email:, password:)
      super()
      @email = email
      @password = password
    end

    def call
      user_id = User.where(email: @email).pluck(:id).last
      if user_id.nil?
        add_error('invalid_email_and_password')
        return
      end

      valid_password = Authentication::Account.find_by(user_id: user_id).authenticate(@password)
      if valid_password
        token = Authentication::AccessToken.generate(user_id)
        @data = {
          access_token: token.token,
          refresh_token: token.refresh_token,
          expires_in: token.expires_in.to_i
        }
      else
        add_error('invalid_email_and_password')
        return
      end
    rescue ActiveRecord::ActiveRecordError => e
      add_error(e)
    end
  end
end
