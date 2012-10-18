# set up logging
require File.expand_path("../logging", __FILE__)

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Tsms::Application.initialize!
