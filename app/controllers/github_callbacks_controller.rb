require 'faraday'
require 'jwt'
require 'octokit'

class GithubCallbacksController < ApplicationController
  def create
    # Exchange the code for a GitHub access token
    access_token = request_to_github_for_token(params[:code])
    github_user_info = get_github_user_info(access_token)
    github_user_info['email'] = get_github_email(access_token)
    puts github_user_info
    github_repos = get_github_repositories(access_token)

    # Find or create a user from the GitHub data
    user = User.find_or_create_from_github(github_user_info,github_repos)

    if user.persisted?
      # Start session or sign-in user with Devise (if used)
      session[:user_id] = user.id
      # Encode the user information into a JWT
      jwt = JwtService.encode(user_id: user.id)

      # Send the JWT and user info back to the client
      render json: { token: jwt, user_id: user.id, username: user.username, email: user.email, github_repos: user.github_repos, github_uid: user.github_uid, github_nickname: user.github_nickname }, status: :ok
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

  def create_repo
    access_token = request_to_github_for_token(params[:code])
    unless access_token
      return render json: { error: 'Error retrieving GitHub access token.' }, status: :bad_request
    end

    github_user_info = get_github_user_info(access_token)
    unless github_user_info
      return render json: { error: 'Error retrieving GitHub user info.' }, status: :bad_request
    end

    # Assuming params[:name] is passed correctly from the frontend
    repo_name = params[:name]
    response = create_github_repository(access_token, repo_name)

    if response[:success]
      render json: { message: 'Repository created successfully.', repo_details: response[:repo_details] }, status: :ok
    else
      render json: { error: response[:error] }, status: response[:status]
    end
  end

  def push_to_github
    project_name = params[:name]
    code = params[:code]

    # Ensure required parameters are present
    if project_name.blank? || code.blank?
      return render json: { error: 'Missing required parameters.' }, status: :bad_request
    end

    # Attempt to retrieve the GitHub access token using the provided code
    access_token = request_to_github_for_token(code)
    return render json: { error: 'Error retrieving GitHub access token.' }, status: :bad_request unless access_token

    # Fetch GitHub user info using the access token
    github_user_info = get_github_user_info(access_token)
    return render json: { error: 'Error retrieving GitHub user info.' }, status: :bad_request unless github_user_info

    # Find the local user by their GitHub ID
    user = User.find_by(github_uid: github_user_info['id'])
    return render json: { error: 'User not found.' }, status: :not_found unless user

    # Initialize the Octokit client with the retrieved access token
    client = Octokit::Client.new(access_token: access_token)

    # Construct the full repository name
    repo_full_name = "#{user.github_nickname}/#{project_name}"

    # Check if the repository already exists
    repo_exists = client.repository?(repo_full_name) rescue false

    unless repo_exists
      # Create the repository if it doesn't exist
      begin
        client.create_repository(project_name.to_s, auto_init: true)
      rescue Octokit::Error => e
        return render json: { error: 'Failed to create GitHub repository.', message: e.message }, status: :unprocessable_entity
      end
    end

    # Construct the local path to the project directory
    project_path = Rails.root.join('storage', user.username, 'Projects', project_name)

    unless Dir.exist?(project_path)
      return render json: { error: 'Project directory does not exist.' }, status: :bad_request
    end

    # Navigate to the project directory and push the project to GitHub
    Dir.chdir(project_path) do
      system('git init')
      system('git add .')
      system('git commit -m "Initial commit"')
      system('git branch -M main')
      system("git remote add origin https://github.com/#{repo_full_name}.git")
      system('git push -u origin main --force')
    end

    # Respond with success
    message = repo_exists ? 'Project updated on GitHub successfully.' : 'Project published to GitHub successfully.'
    render json: { message: message, repo_url: "https://github.com/#{repo_full_name}" }
  rescue => e
    render json: { error: 'An error occurred while pushing to GitHub.', message: e.message }, status: :internal_server_error
  end

  private
  # Adjusted create_github_repository method
  def create_github_repository(access_token, repo_name, options = {})
    Rails.logger.debug { "Creating GitHub repository: #{repo_name} with options: #{options}" }

    # Merge provided options with defaults for repository creation
    options = {
      name: repo_name,
      auto_init: true, # Automatically initialize the repository with a README
      # You can add other default options here as needed
    }.merge(options)

    response = Faraday.post('https://api.github.com/user/repos', options.to_json, {
      'Authorization' => "Bearer #{access_token}",
      'Accept' => 'application/vnd.github+json',
      'Content-Type' => 'application/json'
    })

    case response.status
    when 201
      # Repository created successfully
      { success: true, repo_details: JSON.parse(response.body) }
    when 403
      # Forbidden - the token does not have the right permissions or the resource is not accessible
      { success: false, error: "Forbidden - the token does not have the right permissions or the resource is not accessible", status: :forbidden }
    when 422
      # Unprocessable Entity - the request was well-formed but unable to be followed due to semantic errors
      { success: false, error: "Unprocessable Entity - the request was well-formed but unable to be followed due to semantic errors", status: :unprocessable_entity }
    else
      # Log detailed error information from GitHub
      Rails.logger.error { "Error creating GitHub repository: Status: #{response.status}, Response: #{response.body}" }
      { success: false, error: "Error creating GitHub repository: Status: #{response.status}, Response: #{response.body}", status: :internal_server_error }
    end
  rescue Faraday::Error => e
    # Log any exceptions raised during the HTTP request to GitHub
    Rails.logger.error { "Faraday exception in create_github_repository: #{e.message}" }
    { success: false, error: "Exception while creating GitHub repository: #{e.message}", status: :internal_server_error }
  end




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
  def get_github_email(access_token)
    response = Faraday.get('https://api.github.com/user/emails', {}, {
      'Authorization' => "token #{access_token}",
      'Accept' => 'application/json'
    })

    # Parse the JSON response
    begin
      emails = JSON.parse(response.body)
      puts emails
    rescue JSON::ParserError => e
      puts "Failed to parse JSON: #{e.message}"
      return nil
    end

    # Check if the response is as expected
    unless emails.is_a?(Array)
      puts "Unexpected response format: #{emails.inspect}"
      return nil
    end
    # Find the primary email address that is also private
    primary_private_email = emails.find { |email| email['primary'] == true }

    if primary_private_email
      puts "Primary private email: #{primary_private_email['email']}"
      primary_private_email['email']
    else
      puts "No primary private email found."
      nil
    end
  end
end
