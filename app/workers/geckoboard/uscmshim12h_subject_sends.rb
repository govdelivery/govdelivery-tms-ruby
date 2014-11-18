require 'base'

module Geckoboard
  class Uscmshim12hSubjectSends
    include UscmshimHelpers
    include Workers::Base
    sidekiq_options retry:  false,
                    unique: true

    def perform(account_id, basename)
      sql = subject_sends_sql(12, 10)
      sanitized_sql = EmailMessage.send(:sanitize_sql_for_conditions, [sql, account_id, account_id, account_id])
      result = ActiveRecord::Base.connection.select_all(sanitized_sql)

      data = {}
      xlabels = []
      result.rows.each do |subject, timestamp, count|
        data[subject] ||= []
        data[subject] << count
        xlabels << timestamp.in_time_zone(timezone).strftime('%H')
      end
      xlabels.uniq!

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
