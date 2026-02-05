# Load development environment configuration
# This loads API keys and other settings from config/environments/development/development.yml

if Rails.env.development?
  config_file = Rails.root.join("config", "environments", "development", "development.yml")

  if File.exist?(config_file)
    config = YAML.load_file(config_file) || {}

    config.each do |key, value|
      ENV[key.to_s] = value.to_s unless ENV[key.to_s]
    end
  end
end
