# frozen_string_literal: true
require 'fileutils'
class FileWriter
  def initialize(file_path, data, processname, type:)
    raise ArgumentError, "Invalid type. Expected 'b' or 'n'." unless %w[b  n].include?(type)
    @file_path = file_path
    @data = data
    @processname = processname
    @type =type
  end

  def write_data_new
    FileUtils.mkdir_p(File.dirname(@file_path))
    if @type == "n"
      File.open(@file_path, 'w') do |file|
        file.write(@data)
      end
    elsif @type =="b"
      File.open(@file_path, 'wb') do |file|
        file.write(@data)
      end
    else raise TypeError
    end
    # Ensure directory exists


    raise "File creation failed!" unless File.exist?(@file_path)
  end
  def write_data_append
    File.open(@file_path, 'a') do |file|
      file.write(@data)
    end

    File.read(@file_path)
    raise "File creation failed!" unless File.exist?(@file_path)
    puts @processname + @file_path
  end
end
