RSpec.configure do |config|
  config.mock_with :mocha

  config.before(:all) do
    Analytics::PublisherWorker.publisher = Ackapse
    Analytics::PublisherWorker.async_disabled = true
  end
end

require 'rspec/its'
require 'celluloid/test'

module Ackapse
  # Acknowledge published JSON is valid
  extend self

  LOG ||= {}

  def publishJSON(channel, message)
    log_for(channel) << serialize_deserialize_json(message)
  end

  def serialize_deserialize_json(message)
    out = java.io.StringWriter.new
    org.json.simple.JSONValue.writeJSONString(message, out)
    JSON.parse(out.to_s)
  end

  def log_for(channel)
    LOG[channel] ||= []
  end
end
