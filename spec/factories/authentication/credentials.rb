FactoryBot.define do
  factory :credentials, class: Authentication::Credentials do
    user_id { SecureRandom.uuid }
    password { 'password' }
  end
end
