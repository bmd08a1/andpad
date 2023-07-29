require 'bcrypt'

module Authentication
  class Credentials < ActiveRecord::Base
    self.table_name = 'authentication_credentials'

    def authenticate(password)
      BCrypt::Password.new(password_digest) == password
    end

    def password=(password)
      unless password.blank?
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        self.password_digest = BCrypt::Password.create(password, cost: cost)
      end
    end
  end
end
