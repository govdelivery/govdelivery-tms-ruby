require 'json'
require 'base'

module Geckoboard
  class Reporting
    include GeckoboardHelpers
    include Workers::Base
    sidekiq_options retry: false,
                    unique: true

    # 10060, '"CREATED_AT"'
    def perform(account_id, basename, column)
      messages = EmailMessage.where(account_id: account_id)

      time_range, timestamp_range = time_ranges(48, :hour)

      results = grouped_by_time_format(messages, column, time_range, 'HH24')

      data = zeroes(timestamp_range.step(1.hour))
             .merge(results)
             .sort_by(&:first)
             .each_slice(24)
             .map { |period| period.map(&:second).sum}.reverse # today first

      counts = data.map { |v| {text: '', value: v}}

      write_to_file("#{basename}.json", {item: counts}.to_json)
    end
  end
end
