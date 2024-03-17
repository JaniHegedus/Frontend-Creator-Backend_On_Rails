# frozen_string_literal: true

class PageGenByImage
  def initialize(api_key,project="", pages=1,images,languages={},username)
    @api_key = api_key
    @pages = pages
    @project = project
    @images = images
    @languages = languages
    @username = username
  end

  def generate
    @images.each do |image|
      puts "Generating image #{image}"
      make_request_with_image(image)
    end
  end
  def make_request_with_image(image)
    begin
      uri = URI('https://api.openai.com/v1/chat/completions')
      header = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@api_key}" # Ensure @api_key is set properly
      }

      body = {
        model: "gpt-4-vision-preview",
        max_tokens: 4096,
        messages: [
          { role: "system", content: "You are an Image to Website code generator for a webpage." },
          { role: "user", content: [{ type: "image_url", image_url: image }, "Please send me the code of this page in "+@languages.foreach+" languages"] }
        ]
      }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri, header)
      request.body = body.to_json

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        json_response = JSON.parse(response.body)
        # Process your response here
        json_response # Returning the parsed JSON response
      else
        raise "HTTP Error: #{response.code} #{response.message}"
      end
    rescue Net::HTTPTooManyRequests => e
      # Handle retries and exponential backoff
    rescue JSON::ParserError => e
      raise "JSON Parsing Error: #{e.message}"
    rescue Net::HTTPFatalError => e
      raise "HTTP Fatal Error: #{e.message}"
    end
  end
end
