class RegisterCompanyContract < Dry::Validation::Contract
  params do
    required(:company).hash do
      required(:name).filled(:string)
      required(:owner).schema(RegisterUserContract.schema)
    end
  end
end
