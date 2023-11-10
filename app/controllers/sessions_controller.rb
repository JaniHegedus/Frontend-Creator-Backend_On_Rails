class SessionsController < ApplicationController

  def create
    identifier = params[:login]
    user = if identifier.include?('@')
             User.find_by(email: identifier.downcase)
           else
             User.find_by(username: identifier)
           end

    if user&.authenticate(params[:password])
      # Encode the user information into a JWT
      token = encode_user_information(user)
      render json: { token: token, user_id: user.id, username: user.username, email: user.email, github_uid: user.github_uid, github_nickname: user.github_nickname, github_repos: user.github_repos }, status: :created
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end
  def destroy
    render json: { status: 200, logged_out: true }
  end
  private
  def encode_user_information(user)
    # This method would utilize a JWT encoder to create a JWT for the user.
    # For simplicity, it's assumed you have a method like `JsonWebToken.encode`
    # which you would have defined in an initializer or the lib directory.
    JwtService.encode(user_id: user.id)
  end

  def auth_failure
    redirect_to root_path, alert: "Authentication failed, please try again."
  end

end
