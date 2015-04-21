require_relative 'base'

# This worker is a hack intended to be temporary.
class ForwardStopsToDcm
  class ShouldExecute < StandardError
    attr_accessor :response_text
  end

  include Workers::Base
  sidekiq_options retry: 25, queue: :webhook

  def self.forward_async!(opts)
    perform_async(opts) if should_forward?(opts['Body'], opts['To'])
  end

  def self.should_forward?(body, to)
    Keyword.stop?(body) && Rails.configuration.shared_phone_numbers.include?(to)
  end

  def perform(opts)
    params_to_forward = %w(To From AccountSid MessageSid SmsSid)
    # Always post with "stop" so DCM will delete the subscriber.
    connection.post(Rails.configuration.dcm[:api_root] + '/api/twilio_requests', opts.select { |k, _v| params_to_forward.include?(k) }.merge('Body' => 'stop'))
  end

  private

  def connection
    @connection ||= Faraday.new do |faraday|
      faraday.use Faraday::Response::Logger, logger if logger
      faraday.use Faraday::Response::RaiseError
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
  end
end
