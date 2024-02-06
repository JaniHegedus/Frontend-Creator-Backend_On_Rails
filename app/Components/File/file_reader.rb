# frozen_string_literal: true
require_relative 'file_writer'

class FileReader
  def initialize(file_path)
    @file_path = file_path
  end

  def read_data
    if File.exist?(@file_path)
      puts "The file exists."
      File.read(@file_path)
    else
      FileWriter.new(@file_path, "", "FileReader", type: "n").write_data_append
      puts "The file is now created at: #{@file_path}"
      # Consider what to return here, e.g., empty string or nil
    end
  rescue StandardError => e
    # Handle other file reading errors, log them or re-raise
    puts "An error occurred: #{e.message}"
    # Depending on your use case, you might want to return a default value here
  end
end
