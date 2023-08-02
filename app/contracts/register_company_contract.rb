class RegisterCompanyContract < Dry::Validation::Contract
  params do
    required(:company).hash do
      required(:name).filled(:string)

      required(:owner).hash do
        required(:email).filled(:string)
        required(:first_name).filled(:string)
        required(:last_name).filled(:string)
        required(:password).filled(:string)
        required(:password_confirmation).filled(:string)
      end
    end
  end

  rule('company.owner.password', 'company.owner.password_confirmation') do
    if values[:company][:owner][:password] != values[:company][:owner][:password_confirmation]
      key.failure('password_confirmation does not match')
    end
  end
end
