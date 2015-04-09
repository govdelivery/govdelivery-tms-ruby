module Geckoboard
  module UscmshimHelpers
    def zeroes(timestamps)
      # start with 0 for every hour
      timestamps.reduce({}) do |memo, i|
        # Time objects work as hash keys regardless of time zone (now=Time.now) == now.utc
        memo.merge(Time.at(i) => 0)
      end
    end

    def grouped_by_time_format(scope, column, time_range, format)
      result = scope
               .where(created_at: time_range)
               .group(%[trunc(#{scope.quoted_table_name}.#{dbconn.quote_column_name(column)}, '#{format}')]).count # hash with Time objs as keys
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

    def subject_sends_by_unit(account_id, number_of_subject_lines = 5, unit = 'hour', units = 12, model_klass = EmailMessage)
      if unit == 'hour'
        trunc_fmt = 'HH24'
        interval = 'HOUR'
        normalize = 24
      elsif unit == 'minute'
        trunc_fmt = 'MI'
        interval = 'MINUTE'
        normalize = 1440
      end
      binds = {
        account_id: account_id,
        period: units,
        number_of_subject_lines: number_of_subject_lines,
        trunc_fmt: trunc_fmt, # HH24 for hour of day, MI for minute of hour
        interval: interval,
        normalize: normalize
      }
      sql = <<-EOL
        select fill_hours.subject,
               fill_hours.hour_of_day,
               nvl(count_, 0) as count_
          from ( select top5.subject,
                        twelve_hours.hour_of_day
                   from (select subject
                           from (select subject
                                   from email_messages
                                  where account_id = :account_id
                                    and created_at > cast(sys_extract_utc(systimestamp-numtodsinterval(:period, :interval)) as date)
                                  group by subject
                                  order by count(*) desc
                                )
                          where rownum <= :number_of_subject_lines
                          union all
                          select 'Other' as subject from dual
                        ) top5,
                        (select trunc(cast(sys_extract_utc(systimestamp) as date), :trunc_fmt) - (rownum/:normalize) as hour_of_day
                           from email_messages
                          where rownum <= :period
                        ) twelve_hours -- cartesian here on purpose
                ) fill_hours
          left join
                ( select nvl(top5.subject, 'Other') as subject,
                         all_data.hour_of_day,
                         nvl(sum(count_), 0) as count_
                    from (select subject,
                                 trunc(created_at, :trunc_fmt) as hour_of_day,
                                 count(*) as count_
                            from email_messages
                           where account_id = :account_id
                             and created_at > cast(sys_extract_utc(systimestamp-numtodsinterval(:period, :interval)) as date)
                           group by subject, trunc(created_at, :trunc_fmt)
                           order by subject, trunc(created_at, :trunc_fmt)
                         ) all_data
                    left join
                         (select *
                            from (select subject
                                    from email_messages
                                   where account_id = :account_id
                                     and created_at > cast(sys_extract_utc(systimestamp-numtodsinterval(:period, :interval)) as date)
                                   group by subject
                                   order by count(*) desc
                                 )
                           where rownum <= :number_of_subject_lines
                         ) top5 on all_data.subject = top5.subject
                   group by nvl(top5.subject, 'Other'),
                            all_data.hour_of_day
                ) rollup_ on fill_hours.subject = rollup_.subject
                         and fill_hours.hour_of_day = rollup_.hour_of_day
         order by fill_hours.subject,
                  fill_hours.hour_of_day
      EOL
      sanitized_sql = model_klass.send(:sanitize_sql_for_conditions, [sql, binds])
      ActiveRecord::Base.connection.select_all(sanitized_sql)
    end

    def series_colors
      [
        '#FCFFF5',
        '#D1DBBD',
        '#91AA9D',
        '#ACF0F2',
        '#EB7F00',
        '#54AC92',
        '#F1B60B',
        '#097178',
        '#9E4292',
        '#9D21D9',
        '#03DAF7',
        '#DF9859',
        '#362B7A',
        '#318741',
        '#ADECFC',
        '#60F4BF',
        '#B8F415',
        '#D5C003',
        '#A352A9',
        '#457216',
        '#E87EC2',
        '#E7ADCC',
        '#2A1EA1',
        '#25477F',
        '#1B48E6',
        '#FDF6CB',
        '#8A337F',
        '#FAA194',
        '#2B9731',
        '#75DBDC',
        '#2CA126'
      ]
    end
  end
end
