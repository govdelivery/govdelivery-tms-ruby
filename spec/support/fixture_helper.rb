module FixtureHelper
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
    Account.create!({:name => "ACME"}.merge(attrs))
  end
end
RSpec.configure do |config|
  config.include FixtureHelper
end