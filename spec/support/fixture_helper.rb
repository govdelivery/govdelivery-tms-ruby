module FixtureHelper
  def create_from_address(attrs={})
    FromAddress.create!({from_email: 'hey@dude.test'}.merge(attrs))
  end

  def create_sms_vendor(attrs={})
    SmsVendor.create!({
      :name => 'name',
      :username => 'username',
      :password => 'secret',
      :from=>'+15555555555',
      :worker => 'LoopbackMessageWorker'}.merge(attrs))
  end

  def create_voice_vendor(attrs={})
    VoiceVendor.create!({
                          :name => 'voice vendor',
                          :username => 'username',
                          :password => 'secret',
                          :from=>'+15555551111',
                          :worker => 'LoopbackMessageWorker'}.merge(attrs))
  end

  def create_email_vendor(attrs={})
    EmailVendor.create!({:name => 'new name', :worker => 'LoopbackMessageWorker'}.merge(attrs))
  end

  def create_account(attrs={})
    Account.new({:name => "ACME", dcm_account_codes: ['ACME']}.merge(attrs)).tap do |a|
      a.build_from_address({from_email: 'hey@dude.test'})
      a.save!
    end
  end
end
RSpec.configure do |config|
  config.include FixtureHelper
end