require_relative 'base'

# This worker is a hack intended to be temporary.
class ForwardStopsToDcm
  class ShouldExecute < StandardError
    attr_accessor :response_text
  end

  include Workers::Base
  sidekiq_options retry: 25, queue: :webhook

  ##
  # A stop request should be forwarded to CC for global removal there if:
  #   * The message text begins with a STOP word (i.e. it is a global stop request)
  #   * The number that the stop word was sent to is a shared number as defined by
  #     config/config.yml.
  #
  # The meaning of "shared" is that the number is being used in both TMS (XACT)
  # and CC (BP2) for sending.
  #
  # Messages are *not* forwarded to CC if the text message does not start with a
  # stop word. If the message begins with an account keyword and has a stop word
  # after that, the stop request is handled for that account.
  #
  # If an account is using a number for SMS sending in BP2 and it is not marked
  # as "shared" in XACT, and the number is configured to point incoming text
  # messages to XACT via Twilio, global stop messages will not make it to CC for subscriber
  # removal.
  def self.verify_and_forward!(body, to, from, sid, account_sid)
    perform_async(forward_params: {
      'To'         => to,
      'From'       => from,
      'MessageSid' => sid,
      'SmsSid'     => sid,
      'AccountSid' => account_sid
    }) if should_forward?(body, to)
  end

  def self.should_forward?(body, to)
    Keyword.stop?(body) && Rails.configuration.shared_phone_numbers.include?(to)
  end

  def perform(opts)
    raise Sidekiq::Retries::Fail.new(nil, 'nothing to forward') unless opts['forward_params'].present?
    # Always post with "stop" so DCM will delete the subscriber.
    connection.post(Rails.configuration.dcm[:api_root] + '/api/twilio_requests', opts['forward_params'].merge('Body' => 'stop'))
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
