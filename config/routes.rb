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
  get '/test/PageGenerationTest', to: 'generation_controller_old#generate_page'

  # Sessions
  post 'login', to: 'sessions#create'

  # Users
  post 'register', to: 'users#create'

  # GitHub Webhooks
  post '/github_webhooks', to: 'webhooks#github'

  # CSRF
  get '/csrf', to: 'csrf#token'

  # Logout
  delete '/logout', to: 'sessions#destroy'

  # Define a route to get user details
  get '/user/:id', to: 'users#show'
  get '/userinfo', to: 'users#userinfo'
  # Defines the root path route ("/")
  patch '/user/modify', to: 'users#modify_userinfo' # For partial updates
  delete '/user/delete', to: 'users#destroy'
  post '/reset-password', to: 'users#reset_password'
  # Adding a route for GitHub-based user creation or updates
  post '/auth/github/callback', to: 'github_callbacks#create'
  post '/auth/github', to: 'github_callbacks#auth_github'
  post '/auth/github/remove', to: 'github_callbacks#remove_github'
  post '/github/create_repo', to: 'github_callbacks#create_repo'
  post '/github/publish_repo', to: 'github_callbacks#push_to_github'
  # root "posts#index"
  # Uploads

  resources :uploads, only: [:create]
  post '/uploads', to: 'uploads#create'
  #Generation
  post '/generation', to: 'page_generation#create'

  get '/user_files/:username', to: 'user_files#index'
  get '/user_file', to: 'user_files#return_a_file'

  post '/user_file_update', to: 'user_files#update'

  get '/download_project', to: 'user_files#download_project'
  get '/download_directory', to: 'user_files#download_directory'
  get '/download_file', to: 'user_files#download_file'
  get '/download', to: 'user_files#download'
  post '/user_file/modify_storage', to: 'user_files#user_directory_update'
end
