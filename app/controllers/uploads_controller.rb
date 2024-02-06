# app/controllers/uploads_controller.rb
class UploadsController < ApplicationController
  before_action :authenticate_user!

  def create
    uploaded_file = params[:file]
    username = params[:username]
    user_directory = Rails.root.join('storage', username.to_s)
    FileUtils.mkdir_p(user_directory) unless Dir.exist?(user_directory)

    file_path = user_directory.join(uploaded_file.original_filename)

    File.open(file_path, 'wb') do |file|
      file.write(uploaded_file.read)
    end

    # You can add logic here to save file details in the database if needed

    render json: { message: 'File uploaded successfully', filename: uploaded_file.original_filename }, status: :created
  end

  private

  def authenticate_user!
    # Add your authentication logic here
  end
end
