require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'awesome_print'
require 'colored'
require 'mail'
require 'pry'

module TmsClientManager

  def from_configatron(conf)
    GovDelivery::TMS::Client.new(conf.xact.user.token, api_root: conf.xact.url)
  end

  # TODO: this was in voice_endtoend.rb but got used all over the place, not sure what it's intended to be
  def voice_client
    @voice_client ||= GovDelivery::TMS::Client.new(voice_token, api_root: api_root)
  end

  # TODO: Ostensibly an admin user, not sure
  def admin_client
    @admin_client ||= GovDelivery::TMS::Client.new(admin_token, api_root: api_root)
  end

  def sms_regression_client
    @sms_regression_client ||= if ENV['XACT_ENV'] == 'qc'
      GovDelivery::TMS::Client.new('yopyxmk8NBnr5sa9dxwgf9sEiXpiWv1z', api_root: 'https://qc-tms.govdelivery.com') # will send from (612) 255-6254
    elsif ENV['XACT_ENV'] == 'integration'
      GovDelivery::TMS::Client.new('hycb4FaXB745xxHYEifQNPdXpgrqUtr3', api_root: 'https://int-tms.govdelivery.com') # will send from (612) 255-6225
    elsif ENV['XACT_ENV'] == 'stage'
      GovDelivery::TMS::Client.new('pt8EuddxvVSnEcSZojYx8TaiDFMCpiz2', api_root: 'https://stage-tms.govdelivery.com') # will send from (612) 255-6247
    elsif ENV['XACT_ENV'] == 'prod'
      GovDelivery::TMS::Client.new('7sRewyxNYCyCYXqdHnMFXp8PSvmpLqRW', api_root: 'https://tms.govdelivery.com') # THIS TEST DOESNT RUN IN PROD
    end
  end

  def non_admin_token
    if ENV['XACT_ENV'] == 'qc'
      '2nUnEBWJ362at369KLqgdzR1gGp6meQo' # "id": 10460, "account_id": 10120, "email": "securitytest@evotest.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'integration'
      'qJ71WByLHx53Z296Lpkxs9LcCVU6x2gh' # "id": 10320, "account_id": 10060, "email": "cuke-user-int@evotest.govdelivery.com", "admin": false
    elsif ENV['XACT_ENV'] == 'stage'
      'pzYSpUsoFXx6GKX7jzoQbstsMDyb9f6X' # "id": 11320,"account_id": 10360,"email": "cuke-user-stage@evotest.govdelivery.com","admin": false
    end
  end

  def url
    if ENV['XACT_ENV'] == 'qc'
      'https://qc-tms.govdelivery.com/accounts'
    elsif ENV['XACT_ENV'] == 'integration'
      'https://int-tms.govdelivery.com/accounts'
    elsif ENV['XACT_ENV'] == 'stage'
      'https://stage-tms.govdelivery.com/accounts'
    end
  end

  def from_email
    if ENV['XACT_ENV'] == 'qc'
      'cukeautoqc@govdelivery.com'
    elsif ENV['XACT_ENV'] == 'integration'
      'cukeautoint@govdelivery.com'
    elsif ENV['XACT_ENV'] == 'stage'
      'cukestage@govdelivery.com'
    end
  end

  def account_code
    if ENV['XACT_ENV'] == 'qc'
      'CUKEAUTO_QC'
    elsif ENV['XACT_ENV'] == 'integration'
      'CUKEAUTO_INT'
    elsif ENV['XACT_ENV'] == 'stage'
      'CUKEAUTO_STAGE'
    end
  end

  def mail_accounts
    'xactqctest1@gmail.com'
  end

  def password
    'govdel01!'
  end

  def topic_code
    if ENV['XACT_ENV'] == 'qc'
      'CUKEAUTO_QC_SMS'
    elsif ENV['XACT_ENV'] == 'integration'
      'CUKEAUTO_INT_SMS'
    elsif ENV['XACT_ENV'] == 'stage'
      'CUKEAUTO_STAGE_SMS'
    end
  end


  def subject
    @subject ||= "XACT-533-2 Email Test for link parameters #{Time.new}"
  end

  protected

  def voice_token
    case ENV['XACT_ENV']
      when 'qc'
        '52qxcmfNnD1ELyfyQnkq43ToTcFKDsAZ'
      when 'integration'
        'weppMSnAKp33yi3zuuHdSpN6T2q17yzL'
      when 'stage'
        'Ub7r7CzbzkkSEmF9iVjYSGi98VLgq3qD'
      when 'prod'
        '7sRewyxNYCyCYXqdHnMFXp8PSvmpLqRW'
    end
  end


  def admin_token
    case ENV['XACT_ENV']
      when 'qc'
        '4TvzJZtjAQ8fhaFP6HyFCseq8t7GptSu'
      when 'integration'
        'weppMSnAKp33yi3zuuHdSpN6T2q17yzL'
      when 'stage'
        'Ub7r7CzbzkkSEmF9iVjYSGi98VLgq3qD'
    end
  end


  def api_root
    case ENV['XACT_ENV']
      when 'qc'
        'https://qc-tms.govdelivery.com'
      when 'integration'
        'https://int-tms.govdelivery.com'
      when 'stage'
        'https://stage-tms.govdelivery.com'
      when 'prod'
        'https://tms.govdelivery.com'
    end
  end


  extend self

end
