require 'base64'
require_relative './File/File_writer'
require_relative './File/file_reader'
class ImageProcessor
  def initialize(file_path)
    @file_path = file_path
  end

  def extract_data_from_image
    # Convert the image to a base64 encoded string
    Base64.strict_encode64(File.open(@file_path, 'rb').read)
    #puts Base64.strict_encode64(File.open("Images/Web_Page_Wikipedia.png", 'rb').read)
  end

  def save_extracted_data(data)
    if data == nil
      data = ""
    end
    filename_without_extension = File.basename(@file_path, ".*")
    absolute_path = File.expand_path("test/OUT/#{filename_without_extension}.txt")
    FileWriter.new(absolute_path, data, "ImageProcessor",type:"b").write_data_new
  end
end
