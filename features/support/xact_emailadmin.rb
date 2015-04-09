require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'awesome_print'
require 'colored'
require 'mail'
require 'pry'

class EmailAdmin
  def non_admin
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

  def admin
    if ENV['XACT_ENV'] == 'qc'
      client = GovDelivery::TMS::Client.new('4TvzJZtjAQ8fhaFP6HyFCseq8t7GptSu', api_root: 'https://qc-tms.govdelivery.com')
    elsif ENV['XACT_ENV'] == 'integration'
      client = GovDelivery::TMS::Client.new('weppMSnAKp33yi3zuuHdSpN6T2q17yzL', api_root: 'https://int-tms.govdelivery.com')
    elsif ENV['XACT_ENV'] == 'stage'
      client = GovDelivery::TMS::Client.new('Ub7r7CzbzkkSEmF9iVjYSGi98VLgq3qD', api_root: 'https://stage-tms.govdelivery.com')
    end
  end

  def client
    if ENV['XACT_ENV'] == 'qc'
      client = GovDelivery::TMS::Client.new('4TvzJZtjAQ8fhaFP6HyFCseq8t7GptSu', api_root: 'https://qc-tms.govdelivery.com')
    elsif ENV['XACT_ENV'] == 'integration'
      client = GovDelivery::TMS::Client.new('weppMSnAKp33yi3zuuHdSpN6T2q17yzL', api_root: 'https://int-tms.govdelivery.com')
    elsif ENV['XACT_ENV'] == 'stage'
      client = GovDelivery::TMS::Client.new('Ub7r7CzbzkkSEmF9iVjYSGi98VLgq3qD', api_root: 'https://stage-tms.govdelivery.com')
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
    if ENV['XACT_ENV'] == 'qc'
      'xactqctest1@gmail.com'
    elsif ENV['XACT_ENV'] == 'integration'
      'xactqctest1@gmail.com'
    elsif ENV['XACT_ENV'] == 'stage'
      'xactqctest1@gmail.com'
    end
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
    "XACT-533-2 Email Test for link parameters #{$x}"
  end
end
