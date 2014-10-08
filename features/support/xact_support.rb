#xact support stuff

require 'mechanize'
require 'net/imap'
require 'httpi'
require 'json'
require 'colored'


class XACTHelper
  def send_email(username, password, subject, body, recipient, path)
    @request = HTTPI::Request.new
    @request.url = "#{path}"
    @request.headers["Content-Type"] = "application/json"
    @request.auth.basic(username, password)
    @request.body ='{"subject":"'"#{subject}"'","from_name":"TMStester@evotest.govdelivery.com", "body":"'"#{body}"'", "recipients":[{"email":"'"#{recipient}"'"}]}'
    begin
      @data = HTTPI.post(@request)
      #ap @data.code
      @data.body = JSON.parse(@data.raw_body)
      ap @data.code  
      ap @data.headers
      ap @data.body
    rescue Exception => e
      fail ("Cannot POST email to XACT: " + e.message).red
    end 
    return @data
  end
end

  
class LinkTester
  def test_link(link_url, expected, expected_prefix)
    a = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
       
    ca_path = File.expand_path "lib/Essential.ca-bundle"

    a.agent.http.ca_file = ca_path

    a.get(link_url) do |page|
      page.forms.each do |f|
        return ((f['url'].eql? expected) && (link_url.start_with? expected_prefix))
      end
    end
  end
end

# deletes all email from an IMAP box
class IMAPCleaner
  def clean_inbox(server, port, use_ssl, username, password)
    begin
      imap = Net::IMAP.new(server, port, use_ssl)
      imap.login(username, password)
      imap.select('INBOX')
      messages = imap.search(['ALL']).map do |message_id|
        msg = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
        result = {:mailbox => msg.from[0].mailbox, :host => msg.from[0].host, :subject => msg.subject, :created_at => msg.date}
        imap.store(message_id, "+FLAGS", [:Deleted])
      end
    rescue Exception => e
      puts "Error interacting with #{server} IMAP, trying to delete messages (no retry, will clean up next time): " + e.message
    ensure
      imap.logout
      imap.disconnect
    end
  end
end
