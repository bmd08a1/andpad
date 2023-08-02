FactoryBot.define do
  factory :access_token, class: Authentication::AccessToken do
    user_id { SecureRandom.uuid }
    token { SecureRandom.uuid }
    refresh_token { SecureRandom.uuid }
    created_at { Time.now }
  end
end
