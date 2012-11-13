module FixtureHelper
  def create_vendor(attrs={})
    Vendor.create!({
      :name => 'name', 
      :username => 'username', 
      :password => 'secret', 
      :from => 'from', 
      :worker => 'LoopbackMessageWorker'}.merge(attrs))
  end

  def create_account(attrs={})
    Account.create!({:name => "ACME"}.merge(attrs))
  end
end
RSpec.configure do |config|
  config.include FixtureHelper
end