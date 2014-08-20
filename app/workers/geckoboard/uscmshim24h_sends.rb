module Geckoboard
  require 'base'
  class Uscmshim24hSends
    include Workers::Base
    sidekiq_options retry:  false,
                    unique: true

    def perform(account_id, basename)
      Time.zone = timezone

      now       = Time.now
      end_time  = (now + 1.hour).beginning_of_hour
      start     = end_time - 24.hours
      date_range=start...end_time
      int_range =start.to_i...end_time.to_i

      results=message_counts(date_range, account_id)

      # start with 0 for every hour
      data   =int_range.step(1.hour).reduce({}) { |memo, i|
        memo.merge(Time.at(i).utc => 0)
      }.merge(results).sort_by(&:first)

      counts  = data.map(&:second)
      max     = counts.max
      xlabels = data.map { |x| x.first.in_time_zone(timezone).strftime('%H') }

      output = {
        item:     counts,
        settings: {
          axisx:  xlabels,
          axisy:  [0, max/2, max],
          colour: 'ff9900'
        }}.to_json

      write_to_file("#{basename}.json", output)
    end

    def message_counts(date_range, account_id)
      results=EmailMessage.
        where(account_id: account_id).
        where(created_at: date_range).
        count(group: "trunc(created_at, 'HH24')")
      results.is_a?(Hash) ? results : {}
    end

    def write_to_file(outfile, output)
      dir = File.join(Rails.root, 'public', 'custom_reports')
      File.open(File.join(dir, outfile), 'w') { |file| file.write(output) }
    end

    def timezone
      'Eastern Time (US & Canada)'
    end
  end
end



