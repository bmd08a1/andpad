require_relative 'lib/account'

module Authentication
  class Gateway
    def self.register(user_id:, password:)
      Authentication::Account.create!(user_id: user_id, password: password)
    end
  end
end
