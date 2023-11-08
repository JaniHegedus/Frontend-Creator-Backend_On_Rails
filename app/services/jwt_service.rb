# app/services/jwt_service.rb
require 'jwt'
module JwtService

  HMAC_SECRET = Rails.application.credentials.secret_key_base
  class InvalidToken < StandardError; end
  class ExpiredToken < StandardError; end
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, HMAC_SECRET, 'HS256')
  end

  def self.decode(token)
    body = JWT.decode(token, HMAC_SECRET, true, { algorithm: 'HS256' })[0]
    HashWithIndifferentAccess.new body
  rescue JWT::DecodeError => e
    raise ExceptionHandler::InvalidToken, e.message
  end
end
