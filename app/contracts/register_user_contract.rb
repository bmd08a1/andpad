class RegisterUserContract < Dry::Validation::Contract
  params do
    required(:user).hash do
      required(:email).filled(:string)
      required(:first_name).filled(:string)
      required(:last_name).filled(:string)
      required(:password).filled(:string)
      required(:password_confirmation).filled(:string)
    end
  end

  rule('user.password', 'user.password_confirmation') do
    key.failure('password_confirmation does not match') if values[:user][:password] != values[:user][:password_confirmation]
  end
end
