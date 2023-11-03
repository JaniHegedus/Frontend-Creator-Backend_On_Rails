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
      FileWriter.new(@file_path, "", "FileReader",type: "n").write_data_append
      puts "The file is now Created at:"+ @file_path
    end
  end
end
