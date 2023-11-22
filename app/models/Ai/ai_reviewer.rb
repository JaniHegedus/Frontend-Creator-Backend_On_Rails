require 'net/http'
require 'json'

require_relative '../Components/File/le/file_reader'
require_relative '../Components/File/file_writer'
require_relative '../Components/image_processor'

#ImageAnnotatorClient = Google::Cloud::Vision::V1::ImageAnnotatorClient
#IMAGE_FILE = 'resources/Images/Web_Page_Wikipedia.png'
# Step 2 - Convert the image to base64 format.
#base64_image = Base64.strict_encode64(File.new(IMAGE_FILE, 'rb').read)
#API_KEY = 'AIzaSyBJ9sgvpgOkIZRDKk-sXbglwhzl-wsLsFc' # Don't forget to protect your API key.


class AiReviewer
  def initialize(api_key, filepath, result_type:)
    raise ArgumentError, "Invalid type. Expected 'Label_Detection' or 'google'." unless %w[LABEL_DETECTION  TEXT_DETECTION IMAGE_PROPERTIES].include?(result_type)
    @result_type=result_type
    @filepath = filepath
    @api_key = api_key
    @api_url = "https://vision.googleapis.com/v1/images:annotate?key=#{@api_key}"
    @filename_without_extension = File.basename(@filepath, ".*")
    send_image
  end
  def send_image
    # Step 3 - Set request JSON body.
    body = {
      requests: [{
                   image: {
                     content: ImageProcessor.new(@filepath).extract_data_from_image
                   },
                   features: [
                     {
                       type: @result_type, # Details are below.
                       maxResults: 100 # The number of results you would like to get
                     }
                   ]
                 }]
    }
    # Step 4 - Send request.
    uri = URI.parse(@api_url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    @response = https.request(request, body.to_json)
    # Step 5 - Print the response in the console.
    #puts response.body
  end
  def review_image_to_file(test=false)
    if test
      if @result_type == "LABEL_DETECTION"
        @output_path = File.expand_path("test/OUT/#{@filename_without_extension}/labels.json")
      elsif @result_type == "TEXT_DETECTION"
        @output_path = File.expand_path("test/OUT/#{@filename_without_extension}/texts.json")
      elsif @result_type == "IMAGE_PROPERTIES"
        @output_path = File.expand_path("test/OUT/#{@filename_without_extension}/colors.json")
      else
        "Bad Request Type given"
      end
      if @output_file == ""
        "No filepath"
      else
        FileWriter.new(@output_path,@response.body, "AIReviewer",type:"b").write_data_new
        #client = ::Google::Cloud::Vision::V1::ProductSearch::Client.new
        #request = ::Google::Cloud::Vision::V1::CreateProductSetRequest.new # (request fields as keyword arguments...)
        #response = client.create_product_set request
        #puts response
      end
    else
      if @result_type == "LABEL_DETECTION"
        @output_path = File.expand_path("Resources/OUT/#{@filename_without_extension}/labels.json")
      elsif @result_type == "TEXT_DETECTION"
        @output_path = File.expand_path("Resources/OUT/#{@filename_without_extension}/texts.json")
      elsif @result_type == "IMAGE_PROPERTIES"
        @output_path = File.expand_path("Resources/OUT/#{@filename_without_extension}/colors.json")
      else
        "Bad Request Type given"
      end
      if @output_file == ""
        "No filepath"
      else
        FileWriter.new(@output_path, @response.body, "AIReviewer",type:"b").write_data_new
        #client = ::Google::Cloud::Vision::V1::ProductSearch::Client.new
        #request = ::Google::Cloud::Vision::V1::CreateProductSetRequest.new # (request fields as keyword arguments...)
        #response = client.create_product_set request
        #puts response
      end
    end

  end
  def review_image_to_json
    @response.body
    #client = ::Google::Cloud::Vision::V1::ProductSearch::Client.new
    #request = ::Google::Cloud::Vision::V1::CreateProductSetRequest.new # (request fields as keyword arguments...)
    #response = client.create_product_set request
    #puts response
  end
end
