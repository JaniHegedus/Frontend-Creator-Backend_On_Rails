# frozen_string_literal: true

require 'minitest/autorun'

require_relative '../app/Components/ts/image_processor'
require_relative '../app/Components/AI/ai_reviewer'
require_relative '../app/Components/config'
class ReviewerTest < Minitest::Test
  def setup
    # Create the file first before initializing AiReviewer
    @filepath = "resources/Images/Web_Page_Wikipedia.png"
    unless @filepath
      puts "Image path is not set!"
      return
    end
    @google_key = Config.new(type: "google").load
  end

  def teardown
    # If you have any cleanup steps after tests, add them here.
  end

  def test_image_processor
    # Now initialize ImageProcessor
    @image_processor = ImageProcessor.new(@filepath)
    data = @image_processor.extract_data_from_image
    @image_processor.save_extracted_data(data)
  end
  def test_ai_review_label
    # Now initialize AiReviewer
    @reviewer = AiReviewer.new(@google_key,@filepath,  result_type: "LABEL_DETECTION")
    @reviewer.review_image_to_file(true) # Adjusted the path to make sure it looks in the test folder
    @reviewer.review_image_to_json # Adjusted the path to make sure it looks in the test folder
    puts @reviewer.review_image_to_json
  end
  def test_ai_review_text
    # Now initialize AiReviewer
    @reviewer = AiReviewer.new(@google_key,@filepath, result_type: "TEXT_DETECTION")
    @reviewer.review_image_to_file(true) # Adjusted the path to make sure it looks in the test folder
    @reviewer.review_image_to_json # Adjusted the path to make sure it looks in the test folder
    puts @reviewer.review_image_to_json
  end
  def test_ai_review_colors
    # Now initialize AiReviewer
    @reviewer = AiReviewer.new(@google_key,@filepath, result_type: "IMAGE_PROPERTIES")
    @reviewer.review_image_to_file(true) # Adjusted the path to make sure it looks in the test folder
    @reviewer.review_image_to_json # Adjusted the path to make sure it looks in the test folder
    puts @reviewer.review_image_to_json
  end

end
