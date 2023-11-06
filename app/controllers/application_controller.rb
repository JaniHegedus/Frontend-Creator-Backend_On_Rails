class ApplicationController < ActionController::API
  # Call this method to check for a valid JWT in the 'Authorization' header
  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = JwtService::JwtService.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def authenticate_request!
    token = request.headers['Authorization']&.split(' ')&.last
    if token.blank?
      render json: { error: 'Token not present' }, status: :unauthorized and return
    end

    decoded_token = decode_token(token)

    if decoded_token
      @current_user = User.find_by(id: decoded_token[:user_id])
      unless @current_user
        render json: { error: 'User not found' }, status: :not_found
      end
    else
      render json: { error: 'Not Authenticated' }, status: :unauthorized
    end
  rescue JWT::DecodeError => e
    render json: { errors: e.message }, status: :unauthorized
  end

  private

  def decode_token(token)
    JwtService::JwtService.decode(token)
  end
end
