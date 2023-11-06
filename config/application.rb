require_relative 'boot'
require 'rails/all'
module FrontendCreator
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.autoload_paths << Rails.root.join('app/services')
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Initialize session options before using them
    config.session_store :cookie_store, key: '_interslice_session'
    config.middleware.use ActionDispatch::Cookies # Required for all session management
    config.middleware.use ActionDispatch::Session::CookieStore, config.session_options
    # Rest of your configuration...

    # Comment this out if you are not building an API only application
    config.api_only = true
  end
end
