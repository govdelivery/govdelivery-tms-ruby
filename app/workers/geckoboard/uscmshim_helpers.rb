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

    def subject_sends_by_hour(account_id, number_of_subject_lines=5, hours=12, model_klass=EmailMessage)
      binds = {
        account_id: account_id,
        hours: hours,
        number_of_subject_lines: number_of_subject_lines,
        trunc_fmt: 'HH24' # HH24 for hour of day, MI for minute of hour
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
                                    and created_at > cast(sys_extract_utc(systimestamp-numtodsinterval(:hours,'HOUR')) as date)
                                  group by subject
                                  order by count(*) desc
                                )
                          where rownum <= :number_of_subject_lines
                          union all
                          select 'Other' as subject from dual
                        ) top5,
                        (select trunc(cast(sys_extract_utc(systimestamp) as date), :trunc_fmt) - (rownum/24) as hour_of_day
                           from email_messages
                          where rownum <= :hours
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
                             and created_at > cast(sys_extract_utc(systimestamp-numtodsinterval(:hours,'HOUR')) as date)
                           group by subject, trunc(created_at, :trunc_fmt)
                           order by subject, trunc(created_at, :trunc_fmt)
                         ) all_data
                    left join
                         (select *
                            from (select subject
                                    from email_messages
                                   where account_id = :account_id
                                     and created_at > cast(sys_extract_utc(systimestamp-numtodsinterval(:hours,'HOUR')) as date)
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
  end
end