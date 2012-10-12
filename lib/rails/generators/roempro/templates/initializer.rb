require 'yaml'

# Retrieve the values from config/roempro.yml
config_values = YAML.load_file File.join(Rails.root, 'config', 'roempro.yml')

# Load the configuration into Roempro
Roempro.load_config config_values[Rails.env.to_s]
