FactoryBot.define do
  factory :team, class: CompanyStructure::Team do
    manager_id { SecureRandom.uuid }
    name { 'name' }
  end
end
