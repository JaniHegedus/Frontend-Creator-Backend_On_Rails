class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    # Assuming you are getting email and password directly rather than under :session
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      render json: { id: user.id, email: user.email, username: user.username }, status: :created
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  def destroy
    reset_session
    render json: { status: 200, logged_out: true }
  end
end
