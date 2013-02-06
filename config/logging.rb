require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
require 'log4r/formatter/patternformatter'
Log4r::PatternFormatter::DirectiveTable["h"] = 'Thread.current.object_id.to_s(36)' # This is the same thread id that sidekiq uses
config = Log4r::YamlConfigurator
config['FILE_NAME'] = "xact_#{ENV['RAILS_ENV'] || 'development'}.log"
config['LOG_DIR']   = File.expand_path("../../log", __FILE__)
config.load_yaml_file(File.expand_path("../log4r.yml", __FILE__))