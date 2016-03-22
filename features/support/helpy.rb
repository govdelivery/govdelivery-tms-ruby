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

  def expected_link_prefix
    case ENV['XACT_ENV']
      when 'qc'
        'http://qc-links.govdelivery.com:80'
      when 'integration'
        'http://int-links.govdelivery.com:80'
      when 'stage'
        'http://stage-links.govdelivery.com:80/track'
      when 'prod'
        'https://odlinks.govdelivery.com'
    end
  end

  def api_root
    @conf_xact.url
  end

  def messages_path
    '/messages/email'
  end

  def path
    api_root+messages_path
  end

  def post_message(opts={})
    next if dev_not_live?
    opts[:body]   ||= %Q|This is a test for end to end email delivery. <a href="#{@expected_link}">With a link</a>|
    email_message = GovDelivery::TMS::Client.
      new(@conf_xact.user.token, api_root: api_root).
      email_messages.build(
      from_email: opts[:from_email],
      macros:     opts[:macros],
      body:       opts[:body],
      subject:    @expected_subject
    )
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

    if (mail = emails.detect { |mail| mail.subject == expected_subject })
      [mail.html_part.body.decoded,
       mail.header.fields.detect { |field| field.name == 'Reply-To' }.value,
       mail.header.fields.detect { |field| field.name == 'Errors-To' }.value]
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

  # Polls mail server for messages and validates message if found
  def validate_message
    next if dev_not_live?

    GovDelivery::Proctor.backoff_check(10.minutes, "find message #{@expected_subject}") do
      # get message
      body, reply_to, errors_to = get_emails(@expected_subject)
      passed = false
      unless body.nil?

        # validate from address information
        raise "Expected Reply-To of #{@expected_reply_to} but got #{reply_to}" if @expected_reply_to && reply_to != @expected_reply_to
        raise "Expected Errors-To of #{@expected_errors_to} but got #{errors_to}" if @expected_errors_to && errors_to != @expected_errors_to

        # validate link is present
        if @expected_link &&
          (href = Nokogiri::HTML(body).css('a').
            map { |link| link['href'] }.
            detect { |href| test_link(href, @expected_link, expected_link_prefix) })
          log.info("Link #{href} redirects to #{@expected_link}".green)
          passed = true
        else
          raise "Message #{@expected_subject} was found but no links redirect to #{@expected_link}".red
        end
      end
      return passed
    end
  ensure
    clean_inbox
  end

  def test_link(link_url, expected, expected_prefix)
    Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
      agent.redirect_ok      = false
    end.get(link_url) do |page| # retrieve link_url from agent
      page.forms.any? { |f| ((f['url'].eql? expected) && (link_url.start_with? expected_prefix)) }
    end
  end

end