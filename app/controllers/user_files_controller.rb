require 'zip'
require 'fileutils'
class UserFilesController < ApplicationController

  def index
    user_directory = Rails.root.join('storage', params[:username])
    if Dir.exist?(user_directory)
      render json: { files: list_files(user_directory) }
    else
      render json: { error: 'User files not found' }, status: :not_found
    end
  end

  def return_a_file
    path = params[:file_path].to_s

    # Security measure: Reject if the path attempts directory traversal
    if path.include?("..")
      render json: { error: 'Invalid file path' }, status: :bad_request
      return
    end
    sanitized_path = path.delete('\"')

    # Using File.join ensures the path is correctly constructed for the OS
    local_path = File.join('storage', sanitized_path)

    puts local_path # This will correctly output the full path to the console

    if File.exist?(local_path) && !File.directory?(local_path)
      # Read and return the file content
      file_content = File.read(local_path)
      render json: { content: file_content }
    else
      render json: { error: 'File not found or is a directory' }, status: :not_found
    end
  end

  def update
    path = params[:file_path].to_s
    code = params[:code].to_s
    # Security measure: Reject if the path attempts directory traversal
    if path.include?("..")
      render json: { error: 'Invalid file path' }, status: :bad_request
      return
    end

    sanitized_path = path.delete('\"')

    # Using File.join ensures the path is correctly constructed for the OS
    local_path = File.join('storage', sanitized_path)

    # Check if the file exists and is not a directory
    if File.exist?(local_path) && !File.directory?(local_path)
      # Update the file content
      File.write(local_path, code)
      render json: { message: 'File updated successfully' }
    else
      render json: { error: 'File not found or is a directory '+local_path }, status: :not_found
    end
  end
  def user_directory_update
    # Attempt to find the user based on the username provided
    user = User.find_by(username: params[:username])

    if user
      # Assuming your user's directory is stored in a format like 'storage/USERNAME'
      old_directory_path = "storage/#{params[:username]}"
      new_directory_path = "storage/#{params[:new_directory]}"

      # Check if the old directory exists and the new directory does not exist to prevent overwriting
      if File.directory?(old_directory_path) && !File.directory?(new_directory_path)
        # Use FileUtils to rename the directory
        FileUtils.mv(old_directory_path, new_directory_path)

        render json: { success: "Directory renamed successfully." }, status: :ok
      else
        render json: { error: "Directory cannot be renamed. It might not exist or the new directory name is already in use." }, status: :unprocessable_entity
      end
    else
      render json: { error: "User not found." }, status: :not_found
    end
  rescue StandardError => e
    # Catch and return any errors encountered during the process
    render json: { error: "An error occurred: #{e.message}" }, status: :internal_server_error
  end
  def download_project
    username = params[:username]
    project_name = params[:projectName]

    # Check if the parameters are not present or trying to traverse directories
    if username.blank? || project_name.blank? || username.include?("..") || project_name.include?("..")
      render json: { error: 'Invalid parameters' }, status: :bad_request
      return
    end

    project_directory = Rails.root.join('storage', username, 'Projects', project_name)

    # Check if the project directory exists
    unless Dir.exist?(project_directory)
      render json: { error: 'Project not found' }, status: :not_found
      return
    end

    zipfile_name = Rails.root.join('storage', username, "#{project_name}.zip")

    Zip::File.open(zipfile_name, create: true) do |zipfile|
      Dir[File.join(project_directory, '**', '**')].each do |file|
        zipfile.add(file.sub(project_directory.to_s + '/', ''), file)
      end
    end

    # Stream the zip file back to the client
    send_file(zipfile_name, type: 'application/zip', disposition: 'attachment', filename: "#{project_name}.zip")

    # Optional: Remove the zip file after sending it
    Thread.new do
      sleep(1) # Sleep for 10 seconds
      File.delete(zipfile_name) if File.exist?(zipfile_name)
    end
  end
  def download_file
    username = params[:username]
    file_name = params[:filename]

    if username.blank? || file_name.blank?
      render json: { error: 'Invalid parameters' }, status: :bad_request
      return
    end
    file_path = Rails.root.join('storage', username, file_name)
    puts file_path
    content_type = Mime::Type.lookup_by_extension(File.extname(file_path).delete('.')).to_s
    content_type = 'application/octet-stream' if content_type.blank? # Fallback if MIME type is not found

    unless File.exist?(file_path) && File.file?(file_path)
      render json: { error: 'File not found' }, status: :not_found
      return
    end
    puts file_name
    send_file(file_path, type: content_type, disposition: 'attachment', filename: "#{file_name}")
  rescue => e
    logger.error "Error downloading file: #{e.message}"
    render json: { error: 'An unexpected error occurred' }, status: :internal_server_error
  end
  def download_directory
    username = params[:username]
    directory_name = params[:filename]

    # Check if the parameters are not present or trying to traverse directories
    if username.blank? || directory_name.blank? || username.include?("..") || directory_name.include?("..")
      render json: { error: 'Invalid parameters' }, status: :bad_request
      return
    end

    project_directory = Rails.root.join('storage', username, directory_name)

    # Check if the project directory exists
    unless Dir.exist?(project_directory)
      render json: { error: 'Project not found' }, status: :not_found
      return
    end

    zipfile_name = Rails.root.join('storage', username, "#{directory_name}.zip")

    Zip::File.open(zipfile_name, create: true) do |zipfile|
      Dir[File.join(project_directory, '**', '**')].each do |file|
        zipfile.add(file.sub(project_directory.to_s + '/', ''), file)
      end
    end

    # Stream the zip file back to the client
    send_file(zipfile_name, type: 'application/zip', disposition: 'attachment', filename: "#{directory_name}.zip")

    # Optional: Remove the zip file after sending it
    Thread.new do
      sleep(1) # Sleep for 10 seconds
      File.delete(zipfile_name) if File.exist?(zipfile_name)
    end
  end
  def download
    username = params[:username]

    # Check if the parameters are not present or trying to traverse directories
    if username.blank?|| username.include?("..")
      render json: { error: 'Invalid parameters' }, status: :bad_request
      return
    end

    project_directory = Rails.root.join('storage', username)

    # Check if the project directory exists
    unless Dir.exist?(project_directory)
      render json: { error: 'Project not found' }, status: :not_found
      return
    end

    zipfile_name = Rails.root.join('storage', username, "#{username}.zip")

    Zip::File.open(zipfile_name, create: true) do |zipfile|
      Dir[File.join(project_directory, '**', '**')].each do |file|
        zipfile.add(file.sub(project_directory.to_s + '/', ''), file)
      end
    end

    # Stream the zip file back to the client
    send_file(zipfile_name, type: 'application/zip', disposition: 'attachment', filename: "#{username}.zip")

    # Optional: Remove the zip file after sending it
    Thread.new do
      sleep(1) # Sleep for 10 seconds
      File.delete(zipfile_name) if File.exist?(zipfile_name)
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
end
