# frozen_string_literal: true
IMAGE_FILE = 'resources/Images/Web_Page_Wikipedia.png'
API_KEY = 'AIzaSyBJ9sgvpgOkIZRDKk-sXbglwhzl-wsLsFc' # Don't forget to protect your API key.
API_URL = "https://vision.googleapis.com/v1/images:annotate?key=#{API_KEY}"
def test_Google_Cloud_Vision
  require 'base64'
  require 'json'
  require 'net/https'
  # Step 1 - Set path to the image file, API key, and API URL.
  # Step 2 - Convert the image to base64 format.
  base64_image = Base64.strict_encode64(File.new(IMAGE_FILE, 'rb').read)
  # Step 3 - Set request JSON body.
  body = {
    requests: [{
                 image: {
                   content: base64_image
                 },
                 features: [
                   {
                     type: 'LABEL_DETECTION', # Details are below.
                     maxResults: 100 # The number of results you would like to get
                   }
                 ]
               }]
  }
  # Step 4 - Send request.
  uri = URI.parse(API_URL)
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri)
  request["Content-Type"] = "application/json"
  response = https.request(request, body.to_json)
  # Step 5 - Print the response in the console.
  puts response.body
end