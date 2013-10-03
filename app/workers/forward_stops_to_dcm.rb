require_relative 'base'

# This worker is a hack intended to be temporary.
class ForwardStopsToDcm
  include Workers::Base
  sidekiq_options retry: 25

  def self.forward_async!(opts)
    perform_async(opts) if should_forward?(opts)
  end

  def self.should_forward?(opts)
    Keyword.stop?(opts['Body']) && Rails.configuration.shared_phone_numbers.include?(opts['To'])
  end

  def perform(opts)
    params_to_forward = %w(To From AccountSid MessageSid SmsSid)
    conn = connection
    Rails.configuration.dcm.map{|h|h[:api_root]}.each do |url|
      # Always post with "stop" so DCM will delete the subscriber.
      conn.post(url + '/api/twilio_requests', opts.select{|k,v| params_to_forward.include?(k)}.merge('Body' => 'stop'))
    end
  end

  private

  def connection
    Faraday.new do |faraday|
      faraday.use Faraday::Response::Logger, Rails.logger if self.logger
      faraday.use Faraday::Response::RaiseError
      faraday.adapter :typhoeus
    end
  end
end