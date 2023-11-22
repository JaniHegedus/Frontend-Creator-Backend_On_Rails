require_relative '../models/Ai/Ai/code_generator'
require_relative '../Components/File/file_reader'
require_relative '../Components/config'

class PageGenerationController < ApplicationController
  def initialize

    @openai_api_key = Rails.application.credentials.openai_api_key
    filename_without_extension = File.basename("resources/Images/Web_Page_Wikipedia.png", ".*")
    @output_path_labels = File.expand_path("resources/OUT/#{filename_without_extension}/labels.json")
    @output_path_texts = File.expand_path("resources/OUT/#{filename_without_extension}/texts.json")
    @output_path_colors = File.expand_path("resources/OUT/#{filename_without_extension}/colors.json")
    @filepath = "resources/Images/Web_Page_Wikipedia.png"
    @code_generator = CodeGenerator.new(@openai_api_key, "Texts: "+FileReader.new(@output_path_texts).read_data["description"].to_s+"Dominant colors: "+FileReader.new(@output_path_colors).read_data["dominantColors"].to_s)
    super
  end
  def generate_page
    @code_generator.save_generated_code(@filepath)
    render json: @code_generator.get_response
  end
end
