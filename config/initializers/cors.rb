# Be sure to restart your server when you modify this file.
require 'rack/cors'
# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3000', '127.0.0.1:3000', 'janihegedus.ddns.net:3000', 'janihegedus.ddns.net:3001' # Include any other origins you want to allow
    resource '*',
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options, :head],
             credentials: true
  end
end

