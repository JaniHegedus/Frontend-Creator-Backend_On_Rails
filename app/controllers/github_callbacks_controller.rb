require 'faraday'
require 'jwt'

class GithubCallbacksController < ApplicationController
  def create
    # Exchange the code for a GitHub access token
    access_token = request_to_github_for_token(params[:code])
    github_user_info = get_github_user_info(access_token)
    github_repos = get_github_repositories(access_token)

    # Find or create a user from the GitHub data
    user = User.find_or_create_from_github(github_user_info,github_repos)

    if user.persisted?
      # Start session or sign-in user with Devise (if used)
      session[:user_id] = user.id
      # Encode the user information into a JWT
      jwt = JwtService.encode(user_id: user.id)

      # Send the JWT and user info back to the client
      render json: { token: jwt, user_id: user.id, username: user.username, email: user.email }, status: :ok
    else
      # Handle the situation where the user could not be found or created
      render json: { error: 'Could not authenticate with GitHub.' }, status: :unprocessable_entity
    end
  end

  def auth_github
    # This assumes you have a way of identifying the current user (e.g., via a session or token)
    user = User.find_by(email: params[:email]) # or however you access the current user
    return render json: { error: 'User not found.' }, status: :not_found unless user

    # Exchange the code for a GitHub access token
    access_token = request_to_github_for_token(params[:code])
    return render json: { error: 'Error retrieving GitHub access token.' }, status: :bad_request unless access_token

    #Get Userinfo
    github_user_info = get_github_user_info(access_token)
    return render json: { error: 'Error retrieving GitHub user info.' }, status: :bad_request unless github_user_info
    #Get Repos
    github_repos = get_github_repositories(access_token)
    return render json: { error: 'Error retrieving GitHub repos.' }, status: :bad_request unless github_repos

    # Check if the GitHub ID is already linked to another user
    existing_user_with_github = User.find_by(github_uid: github_user_info['id'])
    if existing_user_with_github && existing_user_with_github != user
      return render json: { error: 'GitHub account is already linked to another user.' }, status: :unprocessable_entity
    end

    # Update the user with GitHub info
    if user.update(github_uid: github_user_info['id'], github_nickname: github_user_info['login'], github_repos: github_repos)
      # Handle successful update, perhaps return the updated user info
      render json: { message: 'GitHub information updated successfully.'}, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def remove_github
    user = User.find_by(email: params[:email]) # or however you access the current user
    return render json: { error: 'User not found.' }, status: :not_found unless user
    # Update the user with GitHub info
    if user.update(github_uid: nil, github_nickname: nil, github_repos: nil)
      # Handle successful update, perhaps return the updated user info
      render json: { message: 'GitHub information removed successfully.' }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def get_github_repositories(access_token)
    response = Faraday.get('https://api.github.com/user/repos', {}, {
      'Authorization' => "token #{access_token}",
      'Accept' => 'application/json'
    })

    case response.status
    when 200
      # Success
      JSON.parse(response.body)
    when 401
      # Unauthorized, token is invalid or expired
      { error: 'GitHub token is invalid or expired.', status: :unauthorized }
    else
      # Other errors, you could handle more cases if needed
      { error: 'Error retrieving GitHub repositories.', status: :bad_request }
    end
  end
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

    case response.status
    when 200
      # Success
      JSON.parse(response.body)
    when 401
      # Unauthorized, token is invalid or expired
      { error: 'GitHub token is invalid or expired.', status: :unauthorized }
    else
      # Other errors, you could handle more cases if needed
      { error: 'Error retrieving GitHub user info.', status: :bad_request }
    end
  end

end
