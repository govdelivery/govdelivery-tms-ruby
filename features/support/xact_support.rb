# xact support stuff

require 'net/imap'
require 'httpi'
require 'json'
require 'colored'

class XACTHelper
  def send_email(username, password, subject, body, recipient, path, from_email, api_key=nil)

    @request = HTTPI::Request.new
    @request.url = "#{path}"
    @request.headers["Content-Type"] = "application/json"

    # if an API key was provided, use it, otherwise fall back
    # to basic auth for backwards compatibility with old tests
    api_key ? @request.headers["X-AUTH-TOKEN"] = api_key : @request.auth.basic(username, password)

    # use a from_email if it was specified, otherwise default will be used
    from_email_json = (from_email ? ", \"from_email\":\"#{from_email}\"" : '')
    @request.body = <<-REQUEST_BODY
      {"subject":"#{subject}","from_name":"TMStester@evotest.govdelivery.com","body":"#{body}","recipients":[{"email":"#{recipient}"}]#{from_email_json}}
    REQUEST_BODY
    begin
      @data = HTTPI.post(@request)
      @data.body = JSON.parse(@data.raw_body)
      log.ap @data.code
      log.ap @data.headers
      log.ap @data.body
    rescue StandardError => e
      raise(('Cannot POST email to XACT: ' + e.message).red)
    end
    @data
  end
end

# deletes all email from an IMAP box
class IMAPCleaner
  def clean_inbox(server, port, use_ssl, username, password)
    imap = Net::IMAP.new(server, port, use_ssl)
    imap.login(username, password)
    imap.select('INBOX')
    imap.search(['ALL']).map do |message_id|
      imap.fetch(message_id, 'ENVELOPE')[0].attr['ENVELOPE']
      imap.store(message_id, '+FLAGS', [:Deleted])
    end
  rescue StandardError => e
    log.error "Error interacting with #{server} IMAP, trying to delete messages (no retry, will clean up next time): #{e.message}"
  ensure
    imap.logout
    imap.disconnect
  end
end
