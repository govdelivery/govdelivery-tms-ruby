require 'base'

module Geckoboard
  class PeriodicReporting
    include Workers::Base

    sidekiq_options retry: false

    def perform(klass, basename, *args)
      geckoboard_accounts = Conf.try(:allowed_geckoboard_accounts) || []
      accounts =  Account.where('id IN ?', geckoboard_accounts)
      accounts.each do |account|
        prefix = Digest::SHA256.hexdigest("#{account.id}")[0..8]
        Geckoboard.const_get(klass).perform_async(account.id, "#{prefix}-#{basename}", *args)
      end
    end
  end
end