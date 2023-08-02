FactoryBot.define do
  factory :company do
    name { 'test' }
    owner_id { SecureRandom.uuid }
  end
end
