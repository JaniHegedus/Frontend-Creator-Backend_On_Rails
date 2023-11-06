Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  #Hello
  get '/hello', to: 'ai#hello'

  #Reviewer
  get '/test/aiImageTest/texts', to: 'ai#texts'
  get '/test/aiImageTest/labels', to: 'ai#labels'
  get '/test/aiImageTest/colors', to: 'ai#colors'

  #PageGen
  get '/test/PageGenerationTest', to: 'page_generation#generate_page'

  # Sessions
  post 'login', to: 'sessions#create'

  # Start the GitHub OAuth process
  get '/auth/github', to: 'github_oauth#start'

  # GitHub OAuth callback
  post '/auth/github/callback', to: 'github_callbacks#create'

  # Users
  post 'register', to: 'users#create'

  # GitHub Webhooks
  post '/github_webhooks', to: 'webhooks#github'

  # CSRF
  get '/csrf', to: 'csrf#token'
  post '/refresh_token', to: 'tokens#refresh'

  # Logout
  delete '/logout', to: 'sessions#destroy'

  # Define a route to get user details
  get '/user/:id', to: 'users#show'
  get '/userinfo', to: 'users#userinfo'
  # Defines the root path route ("/")
  # root "posts#index"
end
