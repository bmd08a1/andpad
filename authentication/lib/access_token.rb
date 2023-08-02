module Authentication
  class AccessToken < ActiveRecord::Base
    self.table_name = 'access_tokens'

    TOKEN_DURATION = 30.minutes
    REFRESH_TOKEN_DURATION = 30.days

    belongs_to :account

    scope :not_expired, -> { where('created_at > (?)::integer', (Time.now - TOKEN_DURATION).to_i) }

    def self.generate(user_id)
      create!(user_id: user_id, token: SecureRandom.uuid, refresh_token: SecureRandom.uuid,
              created_at: Time.now.to_i)
    end

    def self.refresh(access_token, refresh_token)
      current_token = find_by!(token: access_token, refresh_token: refresh_token)

      new_token = generate(current_token.user_id)
      current_token.destroy!

      new_token
    end

    def expires_in
      Time.at(self.created_at + TOKEN_DURATION) - Time.now
    end
  end
end
