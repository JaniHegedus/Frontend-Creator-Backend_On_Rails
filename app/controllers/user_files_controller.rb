class UserFilesController < ApplicationController

  def index
    user_directory = Rails.root.join('storage', params[:username])
    if Dir.exist?(user_directory)
      render json: { files: list_files(user_directory) }
    else
      render json: { error: 'User files not found' }, status: :not_found
    end
  end

  private

  def list_files(path)
    Dir.children(path).map do |entry|
      full_path = File.join(path, entry)
      if File.directory?(full_path)
        { type: 'folder', name: entry, files: list_files(full_path) }
      else
        { type: 'file', name: entry }
      end
    end
  end

  def authenticate_user!
    # Implement your user authentication logic
  end

  def verify_user
    # Ensure the current user is allowed to access the requested files
    # For example, check if params[:username] matches the current user's username
  end
end
