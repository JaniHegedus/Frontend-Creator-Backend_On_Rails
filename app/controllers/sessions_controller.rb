class SessionsController < ApplicationController

  def create
    user = User.find_by(email: params[:email].downcase)
    if user&.authenticate(params[:password])
      # Encode the user information into a JWT
      token = encode_user_information(user)
      render json: { token: token, id: user.id, email: user.email, username: user.username }, status: :created
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  def create_from_github
    # This method is now redundant as it's functionality is
    # covered by the GithubCallbacksController#create action.
    # If you need to trigger this action from a route,
    # you should update the route to point to
    # GithubCallbacksController#create instead.
  end

  private
  def encode_user_information(user)
    # This method would utilize a JWT encoder to create a JWT for the user.
    # For simplicity, it's assumed you have a method like `JsonWebToken.encode`
    # which you would have defined in an initializer or the lib directory.
    JsonWebToken.encode(user_id: user.id)
  end
  def exchange_code_for_token(code)
    client_id = Rails.application.credentials.github[:client_id]
    client_secret = Rails.application.credentials.github[:client_secret]

    response = Faraday.post('https://github.com/login/oauth/access_token') do |req|
      req.params['client_id'] = client_id
      req.params['client_secret'] = client_secret
      req.params['code'] = code
      req.headers['Accept'] = 'application/json'
    end

    token_data = JSON.parse(response.body)
    token_data['access_token']
  end

  def get_github_user_info(access_token)
    response = Faraday.get('https://api.github.com/user') do |req|
      req.headers['Authorization'] = "token #{access_token}"
      req.headers['Accept'] = 'application/json'
    end

    JSON.parse(response.body)
  end

  def auth_failure
    redirect_to root_path, alert: "Authentication failed, please try again."
  end

  def destroy
    render json: { status: 200, logged_out: true }
  end
end
