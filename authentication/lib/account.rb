require 'bcrypt'

module Authentication
  class Account < ActiveRecord::Base
    self.table_name = 'authentication_accounts'

    attr_reader :password

    validates :password, presence: true, length: { minimum: 6 }

    def authenticate(password)
      BCrypt::Password.new(password_digest) == password
    end

    def password=(password)
      @password = password # for validating

      unless password.blank?
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        self.password_digest = BCrypt::Password.create(password, cost: cost)
      end
    end
  end
end
