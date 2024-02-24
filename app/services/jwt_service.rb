# app/services/jwt_service.rb
require 'jwt'

module JwtService
  HMAC_SECRET = Rails.application.credentials.secret_key_base

  # Custom error classes
  class InvalidToken < StandardError; end
  class ExpiredToken < StandardError; end

  # Exception handling module
  module ExceptionHandler
    def self.handle(e)
      case e
      when JWT::ExpiredSignature
        raise ExpiredToken, 'Token has expired.'
      when JWT::DecodeError
        raise InvalidToken, 'Token is invalid.'
      else
        raise StandardError, e.message
      end
    end
  end

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, HMAC_SECRET, 'HS256')
  end

  def self.decode(token)
    body = JWT.decode(token, HMAC_SECRET, true, { algorithm: 'HS256' })[0]
    HashWithIndifferentAccess.new body
  rescue JWT::ExpiredSignature, JWT::DecodeError => e
    ExceptionHandler.handle(e)
  end
end
