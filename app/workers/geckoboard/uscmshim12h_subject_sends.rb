require 'base'

module Geckoboard
  class Uscmshim12hSubjectSends
    include UscmshimHelpers
    include Workers::Base
    sidekiq_options retry:  false,
                    unique: true
    @@series_colors = [
      "#FCFFF5",
      "#D1DBBD",
      "#91AA9D",
      "#ACF0F2",
      "#EB7F00",
      "#54AC92",
      "#F1B60B",
      "#097178",
      "#9E4292",
      "#9D21D9",
      "#03DAF7",
      "#DF9859",
      "#362B7A",
      "#318741",
      "#ADECFC",
      "#60F4BF",
      "#B8F415",
      "#D5C003",
      "#A352A9",
      "#457216",
      "#E87EC2",
      "#E7ADCC",
      "#2A1EA1",
      "#25477F",
      "#1B48E6",
      "#FDF6CB",
      "#8A337F",
      "#FAA194",
      "#2B9731",
      "#75DBDC",
      "#2CA126"
    ]

    def perform(account_id, basename)
      num_of_subject_lines = 10
      result = subject_sends_by_hour(account_id, num_of_subject_lines)

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
        colors: @@series_colors[0..num_of_subject_lines], # Want to include num_of_subject_line + 1 colors, because Others
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
