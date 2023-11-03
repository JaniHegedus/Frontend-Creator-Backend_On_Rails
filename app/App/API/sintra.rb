require 'sinatra'
require 'json'
require 'rack/cors'

require_relative '../..app/Components/AI/ai_reviewer'
require_relative '../../app/Components/AI/'
require_relative '../../app/Components/config'
require_relative '../../app/Components/File/file_reader'
require_relative '../controllers/creator-backend/app/controllers/ai_controller'

google_api_key = Config.new(type: "google").load
openai_api_key = Config.new(type: "openai").load
filename_without_extension = File.basename("resources/Images/Web_Page_Wikipedia.png", ".*")
output_path = File.expand_path("resources/OUT/#{filename_without_extension}.json")
filepath = "resources/Images/Web_Page_Wikipedia.png"
use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :options]
  end
end
# Explicitly set the server to Webrick
set :server, 'webrick'

# Define a route that responds with a JSON message
get '/hello' do
  content_type :json
  { message: 'Hello, Ruby Backend!' }.to_json
end
get '/test/aiImageTest/texts' do
  reviewer = AiReviewer.new(google_api_key,filepath,  result_type: "TEXT_DETECTION")
  reviewer.review_image_to_file
  content_type :json
  reviewer.review_image_to_json
end
get '/test/aiImageTest/labels' do
  reviewer = AiReviewer.new(google_api_key,filepath,  result_type: "LABEL_DETECTION")
  reviewer.review_image_to_file
  content_type :json
  reviewer.review_image_to_json
end
get '/test/aiImageTest/colors' do
  reviewer = AiReviewer.new(google_api_key,filepath,  result_type: "IMAGE_PROPERTIES")
  reviewer.review_image_to_file
  content_type :json
  reviewer.review_image_to_json
end
get '/test/PageGenerationTest' do
  code_generator=CodeGenerator.new(openai_api_key,FileReader.new("OUT/Web_Page_Wikipedia/texts.json"))
  code_generator.save_generated_code(true,filepath)
  code_generator.get_response
end


# You can define more routes and handlers for your application
