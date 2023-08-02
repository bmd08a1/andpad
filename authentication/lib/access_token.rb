module Authentication
  class AccessToken < ActiveRecord::Base
    self.table_name = 'access_tokens'

    TOKEN_DURATION = 30.minutes
    REFRESH_TOKEN_DURATION = 30.days

    belongs_to :account

    def self.generate(user_id)
      create!(user_id: user_id, token: SecureRandom.uuid, refresh_token: SecureRandom.uuid,
              created_at: Time.now.to_i)
    end

    def expires_in
      Time.at(self.created_at + TOKEN_DURATION) - Time.now
    end
  end
end
