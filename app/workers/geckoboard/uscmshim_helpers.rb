module Geckoboard
  module UscmshimHelpers
    def zeroes(timestamps)
      # start with 0 for every hour
      timestamps.reduce({}) { |memo, i|
        # Time objects work as hash keys regardless of time zone (now=Time.now) == now.utc
        memo.merge(Time.at(i) => 0)
      }
    end

    def grouped_by_hour(scope, column, time_range)
      scope.
        where(created_at: time_range).
        count(group: %Q[trunc(#{scope.quoted_table_name}.#{dbconn.quoted_column_name(column)}, 'HH24')]) # hash with Time objs as keys
    end

    def hour_ranges(num_hours)
      # Range's end should be up to but not including one hour from now. This means
      # that part of the range is in the future, which is the desired behavior.
      end_time = (Time.now + 1.hour).beginning_of_hour
      start_time = end_time - num_hours.hours
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
  end
end