class User < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :first_name, presence: true
  validates :last_name, presence: true
end
