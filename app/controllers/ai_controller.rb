# frozen_string_literal: true
require_relative '../models/Ai/ai_reviewer'
require_relative '../Components/config'

class AiController < ApplicationController
  def initialize
    @google_api_key = Rails.application.credentials.google_api_key
    puts @google_api_key
    filename_without_extension = File.basename("resources/Images/Web_Page_Wikipedia.png", ".*")
    @output_path = File.expand_path("resources/OUT/#{filename_without_extension}.json")
    @filepath = "resources/Images/Web_Page_Wikipedia.png"
  end
  def hello
    render json: { message: 'Hello, Ruby Backend!' }
  end

  def texts
    reviewer = AiReviewer.new(@google_api_key, @filepath, result_type: "TEXT_DETECTION")
    reviewer.review_image_to_file
    render json: reviewer.review_image_to_json
  end
  def labels
    reviewer = AiReviewer.new(@google_api_key, @filepath, result_type: "LABEL_DETECTION")
    reviewer.review_image_to_file
    render json: reviewer.review_image_to_json
  end

  def colors
    reviewer = AiReviewer.new(@google_api_key, @filepath, result_type: "IMAGE_PROPERTIES")
    reviewer.review_image_to_file
    render json: reviewer.review_image_to_json
  end
  # ... other methods
end
