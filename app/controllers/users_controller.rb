require_dependency 'jwt_service'
class UsersController < ApplicationController
  before_action :authenticate_request!
  skip_before_action :authenticate_request! , only: [:create,:reset_password, :welcome_email]
  #skip_before_action :verify_authenticity_token, only: [:create], raise: false
  def show
    if @current_user.id == params[:id].to_i
      render json: { email: @current_user.email, username: @current_user.username }
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end
  def userinfo
    # Assuming you have a current_user method set by the authentication process
    if current_user
      render json: current_user, status: :ok
    else
      render json: { error: 'User not found.' }, status: :not_found
    end
  end
  def create
    user = User.new(user_params)
    if user.save
      # For simplicity, we're not returning any authentication token here
      UserMailer.with(user: user).welcome_email.deliver_later
      render json: { id: user.id, email: user.email }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  def modify_userinfo

    # Update user information, password will be automatically hashed by has_secure_password
    if @current_user.update(user_params)
      render json: { message: 'User information updated successfully.' }, status: :ok
    else
      render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  def reset_password
    identifier = params[:login]
    user = if identifier.include?('@')
             User.find_by(email: identifier.downcase)
           else
             User.find_by(username: identifier)
           end

    if user
      new_password = SecureRandom.hex(8) # Generates a 16-character hex string
      user.password = new_password

      if user.save
        # Assuming UserMailer is set up to handle password reset emails
        UserMailer.with(user: user, new_password: new_password).password_reset_email.deliver_later

        render json: { message: 'A new password has been sent to your email address.' }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'User not found.' }, status: :not_found
    end
  end
  def destroy
    if current_user
      if current_user.destroy
        # Sign out the user after deletion to clear the session
        # This is necessary if you are using something like Devise for authentication
        render json: { message: 'User deleted successfully.',logged_out: true }, status: :ok
      else
        # If the user can't be deleted due to some validation failures or callbacks.
        render json: { error: 'User could not be deleted.' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'User not found.' }, status: :not_found
    end
  end

  def welcome_email
    if current_user
      UserMailer.with(@current_user).welcome_email.deliver_later
    end
  end

  private

  def authenticate_request!
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    begin
      @decoded = JwtService.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JwtService::ExpiredToken => e
      # Handle the case where the token has expired
      render json: { errors: 'Token has expired. Please log in again.' }, status: :unauthorized
    rescue JwtService::InvalidToken => e
      # Handle the case where the token is invalid
      render json: { errors: 'Token is invalid. Please log in again.' }, status: :unauthorized
    rescue JWT::DecodeError => e
      # This will catch any other token decoding errors not specifically handled above
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
  def current_user
    @current_user
  end
end