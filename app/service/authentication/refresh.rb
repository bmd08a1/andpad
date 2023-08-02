module Authentication
  class Refresh < BaseService
    def initialize(access_token:, refresh_token:)
      super()
      @access_token = access_token
      @refresh_token = refresh_token
    end

    def call
      new_token = nil
      ActiveRecord::Base.transaction do
        new_token = Authentication::AccessToken.refresh(@access_token, @refresh_token)
      end

      @data = {
        access_token: new_token.token,
        refresh_token: new_token.refresh_token,
        expires_in: new_token.expires_in.to_i
      }
    rescue ActiveRecord::ActiveRecordError
      add_error('cannot_refresh_token')
    end
  end
end
