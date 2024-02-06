# frozen_string_literal: true

require 'minitest/autorun'

require_relative '../app/models/code_generator'
require_relative '../app/Components/file_reader'

class CodeGeneratorTest < Minitest::Test
  def setup
    @openai_key = Config.new(type: "openai").load
    @filepath = "resources/Images/Web_Page_Wikipedia.png"
    @code_generator=CodeGenerator.new(@openai_key,FileReader.new("test/OUT/Web_Page_Wikipedia/texts.json").read_data["description"])
  end

  def teardown
    # Do nothing
  end
  def test_code_saving
    @code_generator.save_generated_code(true,@filepath)
  end
  def test_json_out
    puts @code_generator.get_response
  end
end
