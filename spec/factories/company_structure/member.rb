FactoryBot.define do
  factory :member, class: CompanyStructure::Member do
    user_id { SecureRandom.uuid }
  end
end
