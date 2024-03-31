# frozen_string_literal: true
require 'net/http'
require 'uri'
require 'json'
require 'fileutils'
class PageGenByImage
  def initialize(api_key:, images:, username:, project: "", pages: 1, languages: {})
    puts "Initializing class..."
    puts "Languages parameter: #{languages}"
    puts "Images parameter: #{images}"

    @pagecount = 1

    @api_key = api_key
    @pages = pages
    @project = project
    @images = images
    @languages = languages
    @username = username #Create new project directory if not exist
  end
  def create_project_directory(username, project_name, pagecount=1)
    if @pages > 1
      base_dir = "storage/#{username}/Projects/#{project_name}/#{pagecount}"
    else
      base_dir = "storage/#{username}/Projects/#{project_name}/"
    end
    FileUtils.mkdir_p(base_dir)
    puts "Directory created at: #{base_dir}"
    return base_dir
  rescue StandardError => e
    puts "Failed to create directory: #{e.message}"
  end
  def generate

    @images.each do |image_name, image_path|
      puts "Generating for image #{image_name}"
      # Construct the request string for each language
      language_requests = @languages.map {|key, value| "#{value}"}.join(", ")
      # Now use language_requests in your request
      make_request_with_image(image_path, language_requests) # Pass languages to your request function
      @pagecount+=1
    end
  end

  def make_request_with_image(image, language_requests)
    puts image, language_requests

    puts "Encoding image..."
    base64_encoded_image = Base64ImageService.encode_image_to_base64("storage/"+image)
    puts "Encoding complete!\n Sending..."
    begin
      uri = URI('https://api.openai.com/v1/chat/completions')
      header = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@api_key}"
      }

      # Constructing the languages request string
      content_request = "Please send me the code of this page #{language_requests.to_s}."

      body = {
        model: "gpt-4-vision-preview",
        max_tokens: 4096,
        messages: [
          { role: "system", content: "You are an Image to Website code generator for a webpage." },
          { role: "user",
            content: [
              { type: "text", text: "Please generate website code."},
              { type: "image_url",
              image_url: {
                url: "data:image/jpeg;base64,#{base64_encoded_image}"
              }
              },
              { type: "text", text:content_request }
            ]
          } # Your language-specific request, if needed
        ]
      }
      #puts body
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri, header)
      request.body = body.to_json

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        json_response = JSON.parse(response.body)
        puts "Success! Generating files ..."
        create_files(create_project_directory(@username, @project["projectName"], @pagecount),json_response,@languages)

      else
        puts response.body
        raise "HTTP Error: #{response.code} #{response.message}"
      end
    rescue Net::HTTPTooManyRequests => e
      # Handle retries and exponential backoff
      raise "Too many requests Error (#{e.message})"
    rescue JSON::ParserError => e
      raise "JSON Parsing Error: #{e.message}"
    rescue Net::HTTPFatalError => e
      raise "HTTP Fatal Error: #{e.message}"
    end
  end
  def create_files(project_location,processed_response, languages)
    FileGenerationService.generate_files(project_location,processed_response["choices"][0]["message"]["content"],languages)
    puts "Files created!"
  end
end
