require 'securerandom'

class User < ApplicationRecord
  has_secure_password

  # Add validations as necessary
  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  def self.find_or_create_from_github(github_info)
    # Find user by their GitHub UID or initialize a new user
    user = find_or_initialize_by(github_uid: github_info['id'])

    if user.new_record?
      user.username = github_info['login'] # Handle username collisions if needed
      user.email = github_info['email']
      # Set a random, secure password for the user
      user.password = SecureRandom.hex(10) # This will generate a random 20-character string
      user.github_nickname = github_info['login'] # Make sure to capture any additional needed fields
      # Set other attributes from github_info as needed
      user.save!
      UserMailer.welcome_email(user).deliver_later
    end

    user
  end
end
