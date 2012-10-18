require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
config = Log4r::YamlConfigurator
config['FILE_NAME'] = "tsms_#{Rails.env}.log"
config['LOG_DIR']   = Rails.root.join("log").to_s
config.load_yaml_file(Rails.root.join("config", "log4r.yml"))
Rails.logger = Log4r::Logger['default']