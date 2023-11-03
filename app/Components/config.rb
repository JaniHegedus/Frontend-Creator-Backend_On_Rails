require 'yaml'

class Config
  def initialize(type:)
    raise ArgumentError, "Invalid type. Expected 'openai' or 'google'." unless %w[openai google].include?(type)
    @type = type
  end

  def load
    config = YAML.load_file('config.yml')
    if @type == "openai"
      config['openai_api_key']
    elsif @type == "google"
      config['google_cloud_vision_key']
    else
      nil
    end
  end
end
