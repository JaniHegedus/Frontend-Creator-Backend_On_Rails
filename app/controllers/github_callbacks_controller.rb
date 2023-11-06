require 'faraday'
require 'jwt'

class GithubCallbacksController < ApplicationController
  def create
    # Exchange the code for a GitHub access token
    access_token = request_to_github_for_token(params[:code])
    github_user_info = get_github_user_info(access_token)

    # Find or create a user from the GitHub data
    user = User.find_or_create_from_github(github_user_info)

    # Encode the user information into a JWT
    jwt = JwtService.encode(user_id: user.id)

    # Send the JWT back to the client
    render json: { token: jwt }, status: :ok
  end

  private

  def request_to_github_for_token(code)
    client_id = Rails.application.credentials.github[:client_id]
    client_secret = Rails.application.credentials.github[:client_secret]

    response = Faraday.post('https://github.com/login/oauth/access_token') do |req|
      req.params['client_id'] = client_id
      req.params['client_secret'] = client_secret
      req.params['code'] = code
      req.headers['Accept'] = 'application/json'
    end

    JSON.parse(response.body)['access_token']
  end

  def get_github_user_info(access_token)
    response = Faraday.get('https://api.github.com/user', {}, {
      'Authorization' => "token #{access_token}",
      'Accept' => 'application/json'
    })

    if response.success?
      JSON.parse(response.body)
    else
      # Handle error appropriately
    end
  end

  def encode_user_information(user)
    JwtService.encode(user_id: user.id)
  end

  # If encode_jwt_for_user is still in use, correct it as well
  def encode_jwt_for_user(github_data)
    JwtService.encode(github_data)
  end
end
