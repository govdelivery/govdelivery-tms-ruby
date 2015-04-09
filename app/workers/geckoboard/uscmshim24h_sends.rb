require 'base'

module Geckoboard
  class Uscmshim24hSends
    include UscmshimHelpers
    include Workers::Base
    sidekiq_options retry:  false,
                    unique: true

    def perform(account_id, basename)
      messages = EmailMessage.where(account_id: account_id)
      time_range, timestamp_range = time_ranges(24, :hour)

      results = grouped_by_time_format(messages, 'CREATED_AT', time_range, 'HH24')

      data = zeroes(timestamp_range.step(1.hour)).merge(results).sort_by(&:first)
      counts  = data.map(&:second)
      max     = counts.max
      xlabels = data.map { |x| x.first.in_time_zone(timezone).strftime('%H') }

      output = {
        item:     counts,
        settings: {
          axisx:  xlabels,
          axisy:  [0, max / 2, max],
          colour: 'ff9900'
        } }.to_json

      write_to_file("#{basename}.json", output)
    end
  end
end
