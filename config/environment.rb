# Load the rails application
require File.expand_path('../application', __FILE__)

Rails.logger = Log4r::Logger['default']

# Initialize the rails application
Xact::Application.initialize!
