# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  # Add validations as necessary
  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }

end
