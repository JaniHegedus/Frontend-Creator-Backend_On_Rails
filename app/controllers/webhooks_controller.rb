# frozen_string_literal: true

class WebhooksController < ApplicationController
  #skip_before_action :verify_authenticity_token, only: [:github]
  before_action :verify_github_signature, only: [:github]

  def github
    # Handle the webhook event
    event = request.headers['X-GitHub-Event']
    payload = JSON.parse(request.body.read)

    case event
    when 'push'
      # Handle push event
    when 'pull_request'
      # Handle pull request event
      # Add more cases as per the events you want to handle
    end

    head :ok
  end

  private

  def verify_github_signature
    secret = ENV['GITHUB_WEBHOOK_SECRET']
    request_body = request.body.read
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, request_body)
    unless Rack::Utils.secure_compare(signature, request.headers['X-Hub-Signature'])
      render plain: "Signatures didn't match!", status: :unauthorized
    end
  end


end
