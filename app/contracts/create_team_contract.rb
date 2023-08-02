class CreateTeamContract < Dry::Validation::Contract
  params do
    required(:name).filled(:string)
    required(:manager_id).filled(:string)
  end
end
