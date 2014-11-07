require 'base'

module Geckoboard
  class Uscmshim12hSubjectSends
    include UscmshimHelpers
    include Workers::Base
    sidekiq_options retry:  false,
                    unique: true

    def perform(account_id, basename)
      sql = <<-EOL
        select fill_hours.subject,
               fill_hours.hour_of_day,
               nvl(count_, 0) as count_
          from ( select top5.subject,
                        twelve_hours.hour_of_day
                   from (select subject
                           from (select subject
                                   from email_messages
                                  where account_id = %s
                                    and created_at > cast(sys_extract_utc(systimestamp-numtodsinterval(12,'HOUR')) as date)
                                  group by subject
                                  order by count(*) desc
                                )
                          where rownum <= 5
                          union all
                          select 'Other' as subject from dual
                        ) top5,
                        (select trunc(cast(sys_extract_utc(systimestamp) as date), 'HH24') - (rownum/24) as hour_of_day
                           from email_messages
                          where rownum <= 12
                        ) twelve_hours -- cartesian here on purpose
                ) fill_hours
          left join
                ( select nvl(top5.subject, 'Other') as subject,
                         all_data.hour_of_day,
                         nvl(sum(count_), 0) as count_
                    from (select subject,
                                 trunc(created_at, 'HH24') as hour_of_day,
                                 count(*) as count_
                            from email_messages
                           where account_id = %s
                             and created_at > cast(sys_extract_utc(systimestamp-numtodsinterval(12,'HOUR')) as date)
                           group by subject, trunc(created_at, 'HH24')
                           order by subject, trunc(created_at, 'HH24')
                         ) all_data
                    left join
                         (select *
                            from (select subject
                                    from email_messages
                                   where account_id = %s
                                     and created_at > cast(sys_extract_utc(systimestamp-numtodsinterval(12,'HOUR')) as date)
                                   group by subject
                                   order by count(*) desc
                                 )
                           where rownum <= 5
                         ) top5 on all_data.subject = top5.subject
                   group by nvl(top5.subject, 'Other'),
                            all_data.hour_of_day
                ) rollup_ on fill_hours.subject = rollup_.subject
                         and fill_hours.hour_of_day = rollup_.hour_of_day
         order by fill_hours.subject,
                  fill_hours.hour_of_day
      EOL
      sanitized_sql = EmailMessage.send(:sanitize_sql_for_conditions, [sql, account_id, account_id, account_id])
      result = ActiveRecord::Base.connection.select_all(sanitized_sql)

      data = {}
      xlabels = []
      result.rows.each do |subject, timestamp, count|
        data[subject] ||= []
        data[subject] << count
        xlabels << timestamp.in_time_zone(timezone).strftime('%H')
      end
      xlabels.uniq!.sort!

      series = []
      data.each do |subject, counts|
        series << {
          name: subject,
          marker: {
            symbol: 'circle',
            radius: 4
          },
          lineWidth: 4,
          data: counts
        }
      end

      output = {
        colors: ["#FCFFF5", "#D1DBBD", "#91AA9D", "#ACF0F2", "#EB7F00"],
        credits: {
          enabled: false
        },
        legend: {
          enabled: false
        },
        title: {
          text: nil
        },
        chart: {
          type: 'spline',
          style: {
            color: "#9A9A9A"
          },
          renderTo: "container",
          backgroundColor: "transparent",
          lineColor: "rgba(154,154,154,100)",
          plotShadow: false
        },
        xAxis: {
          categories: xlabels
        },
        yAxis: {
          title: {
            style: {
              color: "#9a9a9a"
            },
            text: 'Sent Messages'
          }
        },
        tooltip: {
          borderColor: "rgba(0,0,0,0.85)",
          backgroundColor: "rgba(0,0,0,0.85)",
          style: {
            color: "#9a9a9a"
          },
          crosshairs: true,
          shared: true
        },
        series: series
      }.to_json
      write_to_file("#{basename}.json", output)
    end
  end
end

{


}
