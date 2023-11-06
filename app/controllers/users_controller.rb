require_dependency 'jwt_service'
class UsersController < ApplicationController
  before_action :authenticate_request!, only: [:show, :userinfo]
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
      render json: { id: user.id, email: user.email }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def github_create
    # Find or create a user based on the GitHub data
    github_user_info = get_github_user_info(params[:access_token])

    user = User.find_or_initialize_by(github_id: github_user_info['id'])
    user.update(
      name: github_user_info['name'],
    # Other fields you want to update...
      )

    if user.persisted?
      render json: { token: user.generate_jwt }, status: :ok
    else
      render json: { error: 'Error message' }, status: :unprocessable_entity
    end
  end

  private

  def get_github_user_info(access_token)
    # Moved
  end
  def authenticate_request!
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    begin
      @decoded = JwtService.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
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