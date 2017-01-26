module Helpy
  def initialize_variables
    Capybara.default_wait_time = 600

    @expected_subject    = 'xact_email_end_to_end - ' + Time.new.to_s + '::' + rand(100_000).to_s
    @link_redirect_works = false
    @expected_link       = 'http://govdelivery.com'
    @conf_xact           = configatron.accounts.email_endtoend.xact
    @conf_gmail          = configatron.accounts.email_endtoend.gmail

    imap_config = @conf_gmail.imap.to_h
    Mail.defaults do
      retriever_method :imap, imap_config
    end
  end

  def api_root
    configatron.xact.url
  end

  def messages_path
    '/messages/email'
  end

  def path
    api_root + messages_path
  end

  def post_message(opts={})
    return if dev_not_live?
    opts[:body] ||= %|This is a test for end to end email delivery. <a href="#{@expected_link}">With a link</a>|
    opts[:from_name] = @from_name unless @from_name.blank?
    opts[:subject] = @expected_subject
    email_message = GovDelivery::TMS::Client
                    .new(@conf_xact.token, api_root: api_root)
                    .email_messages.build(opts)
    email_message.recipients.build(email: @conf_gmail.imap.user_name)
    email_message.post!
    response = email_message.response
    log.ap response.status
    log.ap response.headers
    log.ap response.body
  end

  def get_emails(expected_subject)
    log.info "Checking Gmail IMAP for subject \"#{expected_subject}\""
    emails = Mail.find(what: :last, count: 1000, order: :dsc)
    log.info "Found #{emails.size} emails"
    log.info "subjects:\n\t#{emails.map(&:subject).join("\n\t")}" if emails.any?

    if (mail = emails.detect { |mail| mail.subject == expected_subject})
      [mail.html_part.body.decoded,
       mail.header.fields.detect { |field| field.name == 'Reply-To'}.value,
       mail.header.fields.detect { |field| field.name == 'Errors-To'}.value,
       mail.header.fields.detect { |field| field.name == 'From'}.value]
    else
      nil
    end

  rescue => e
    log.error "Error interacting with Gmail IMAP: #{e.message}"
    log.error e.backtrace
  end

  def clean_inbox
    IMAPCleaner.new.clean_inbox(
      @conf_gmail.imap.address,
      @conf_gmail.imap.port,
      @conf_gmail.imap.enable_ssl,
      @conf_gmail.imap.user_name,
      @conf_gmail.imap.password)
    log.info 'Cleaned inbox'.green
  end

  def test_link(link_url, expected, expected_prefix)
    Mechanize.new do |agent|
      agent.agent.http.reuse_ssl_sessions = false
      agent.user_agent_alias = 'Mac Safari'
      agent.redirect_ok      = true
    end.get(link_url) do |page| # retrieve link_url from agent
      page.forms.any? { |f| ((f['url'].eql? expected) && (link_url.start_with? expected_prefix))}
    end
  end
end
