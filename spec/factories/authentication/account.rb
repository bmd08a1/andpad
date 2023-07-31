FactoryBot.define do
  factory :account, class: Authentication::Account do
    user_id { SecureRandom.uuid }
    password { 'password' }
  end
end
