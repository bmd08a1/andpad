FactoryBot.define do
  factory :user do
    first_name { 'test' }
    last_name { 'test' }
    email { 'test@gmail.com' }
    company_id { SecureRandom.uuid }
  end
end
