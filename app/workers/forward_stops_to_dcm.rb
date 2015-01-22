require_relative 'base'

# This worker is a hack intended to be temporary.
class ForwardStopsToDcm
  include Workers::Base
  sidekiq_options retry: 25, queue: :webhook

  def self.forward_async!(opts)
    perform_async(opts) if should_forward?(opts)
  end

  def self.should_forward?(opts)
    Keyword.stop?(opts['Body']) && Rails.configuration.shared_phone_numbers.include?(opts['To'])
  end

  def perform(opts)
    params_to_forward = %w(To From AccountSid MessageSid SmsSid)
    conn = connection
    # Always post with "stop" so DCM will delete the subscriber.
    conn.post(Rails.configuration.dcm[:api_root] + '/api/twilio_requests', opts.select { |k, v| params_to_forward.include?(k) }.merge('Body' => 'stop'))
  end

  private

  def connection
    Faraday.new do |faraday|
      faraday.use Faraday::Response::Logger, self.logger if self.logger
      faraday.use Faraday::Response::RaiseError
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
  end
end
