class RegisterUserContract < Dry::Validation::Contract
  params do
    required(:email).filled(:string)
    required(:first_name).filled(:string)
    required(:last_name).filled(:string)
    required(:password).filled(:string)
    required(:password_confirmation).filled(:string)
  end

  rule('password', 'password_confirmation') do
    key.failure('password_confirmation does not match') if values[:password] != values[:password_confirmation]
  end
end
