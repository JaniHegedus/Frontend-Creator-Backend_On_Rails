# frozen_string_literal: true

class CsrfController < ApplicationController
  # If you're using Rails 5.2 and above, you might need to skip this for API only applications
  #skip_before_action :verify_authenticity_token

  def token
    render json: { csrf_token: form_authenticity_token }
  end
end