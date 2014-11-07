module Geckoboard
  module UscmshimHelpers
    def zeroes(timestamps)
      # start with 0 for every hour
      timestamps.reduce({}) { |memo, i|
        # Time objects work as hash keys regardless of time zone (now=Time.now) == now.utc
        memo.merge(Time.at(i) => 0)
      }
    end

    def grouped_by_time_format(scope, column, time_range, format)
      result = scope.
        where(created_at: time_range).
        group(%Q[trunc(#{scope.quoted_table_name}.#{dbconn.quote_column_name(column)}, '#{format}')]).count # hash with Time objs as keys
      result.is_a?(Hash) ? result : {} # result==0 when there's nothing to report on
    end

    def time_ranges(num_units, unit)
      # Range's end should be up to now but not including now. This means
      # that part of the range is in the future, which is the desired behavior.
      end_time = Time.now.send(:"beginning_of_#{unit}")
      start_time = end_time - num_units.send(:"#{unit}s")
      time_range = start_time...end_time
      timestamp_range = start_time.to_i...end_time.to_i
      [time_range, timestamp_range]
    end

    def write_to_file(outfile, output)
      File.open(File.join(Rails.root, 'public', 'custom_reports', outfile), 'w') { |file| file.write(output) }
    end

    def dbconn
      ActiveRecord::Base.connection
    end

    def timezone
      'Eastern Time (US & Canada)'
    end
  end
end