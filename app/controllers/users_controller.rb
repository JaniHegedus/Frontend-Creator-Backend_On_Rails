class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create], raise: false

  def create
    user = User.new(user_params)
    if user.save
      # For simplicity, we're not returning any authentication token here
      render json: { id: user.id, email: user.email }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end