class RefreshTokenContract < Dry::Validation::Contract
  params do
    required(:access_token).filled(:string)
    required(:refresh_token).filled(:string)
  end
end
