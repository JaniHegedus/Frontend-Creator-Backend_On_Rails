Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get '/hello', to: 'ai#hello'
  get '/test/aiImageTest/texts', to: 'ai#texts'
  get '/test/aiImageTest/labels', to: 'ai#labels'
  get '/test/aiImageTest/colors', to: 'ai#colors'
  get '/test/PageGenerationTest', to: 'page_generation#generate_page'

  # Defines the root path route ("/")
  # root "posts#index"
end
