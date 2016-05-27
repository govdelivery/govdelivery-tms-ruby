module TmsClientManager

  def from_configatron(conf)
    client_factory(conf.xact.user.token, conf.xact.url)
  end

  # TODO: Ostensibly an admin user, not sure
  def admin_client
    @admin_client ||= client_factory(configatron.tms.admin.token, configatron.tms.api_root)
  end

  def non_admin_client
    @non_admin_client ||= client_factory(configatron.tms.non_admin.token, configatron.tms.api_root)
  end

  def other_non_admin_client
    @other_non_admin_client ||= client_factory(configatron.tms.sms.token, configatron.tms.api_root)
  end

  def non_admin_token
    configatron.tms.non_admin.token
  end

  def url
    configatron.tms.url
  end

  def from_email
    configatron.tms.from_email
  end

  def account_code
    configatron.tms.account_code
  end

  def mail_accounts
    configatron.tms.mail_accounts
  end

  def password
    configatron.tms.password
  end

  def topic_code
    configatron.tms.topic_code
  end

  def subject
    configatron.tms.default_subject
  end

  extend self

  private
  def client_factory(token, root)
    GovDelivery::TMS::Client.new(token, api_root: root, logger: log)
  end
end
