# frozen_string_literal: true
require 'base64'

module Base64ImageService
  # Encodes an image to a Base64 string
  def self.encode_image_to_base64(image_path)
    Base64.strict_encode64(File.binread(image_path))
  end
end
