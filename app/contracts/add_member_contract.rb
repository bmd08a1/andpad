class AddMemberContract < Dry::Validation::Contract
  params do
    required(:member_id).filled(:string)
    required(:team_id).filled(:string)
  end
end
