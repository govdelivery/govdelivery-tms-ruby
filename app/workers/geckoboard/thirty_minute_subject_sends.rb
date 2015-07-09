require 'base'

module Geckoboard
  class ThirtyMinuteSubjectSends
    include GeckoboardHelpers
    include Workers::Base
    sidekiq_options retry:  false,
                    unique: true

    def perform(account_id, basename)
      write_to_file("#{basename}.json", build_data(account_id, basename).to_json)
    end

    def build_data(account_id, _basename)
      num_of_subject_lines = 10
      result               = subject_sends_by_unit(account_id, num_of_subject_lines, 'minute', 30)
      data                 = {}
      xlabels              = []

      result.rows.each do |subject, timestamp, count|
        data[subject] ||= []
        data[subject] << count
        xlabels << timestamp.in_time_zone(timezone).strftime('%M')
      end
      xlabels.uniq!

      series = data.map do |subject, counts|
        {
          name:      subject,
          marker:    {
            symbol: 'circle',
            radius: 4
          },
          lineWidth: 4,
          data:      counts
        }
      end

      {
        colors:  series_colors[0..num_of_subject_lines],
        credits: {
          enabled: false
        },
        legend:  {
          enabled: false
        },
        title:   {
          text: nil
        },
        chart:   {
          type:            'spline',
          style:           {
            color: '#9A9A9A'
          },
          renderTo:        'container',
          backgroundColor: 'transparent',
          lineColor:       'rgba(154,154,154,100)',
          plotShadow:      false
        },
        xAxis:   {
          categories: xlabels
        },
        yAxis:   {
          title: {
            style: {
              color: '#9a9a9a'
            },
            text:  'Sent Messages'
          }
        },
        tooltip: {
          borderColor:     'rgba(0,0,0,0.85)',
          backgroundColor: 'rgba(0,0,0,0.85)',
          style:           {
            color: '#9a9a9a'
          },
          crosshairs:      true,
          shared:          true
        },
        series:  series
      }
    end
  end
end

{

}
