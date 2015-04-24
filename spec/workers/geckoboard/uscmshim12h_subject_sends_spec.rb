require 'rails_helper'

describe Geckoboard::Uscmshim12hSubjectSends do
  let(:account) {create(:account_with_sms)}

  subject {Geckoboard::Uscmshim12hSubjectSends.new}
  before do
    @messages = create_list(:email_message, 12, subject: 'Donkey', account: account)
    @messages.each do |message|
      message.created_at = message.created_at - 1.hour
      message.save!
    end
  end

  it 'writes sending info for subjects for the past 12 hours in json format to disk' do
    end_time = Time.now.beginning_of_hour
    start_time = end_time - 12.hours
    time_range = start_time.to_i...end_time.to_i
    times = time_range.step(1.hour).map { |t| Time.at(t).in_time_zone('Eastern Time (US & Canada)').strftime('%H')}

    subject.expects(:write_to_file).with('name.json', {
      colors: ['#FCFFF5', '#D1DBBD', '#91AA9D', '#ACF0F2', '#EB7F00', '#54AC92', '#F1B60B', '#097178', '#9E4292', '#9D21D9', '#03DAF7'],
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
          color: '#9A9A9A'
        },
        renderTo: 'container',
        backgroundColor: 'transparent',
        lineColor: 'rgba(154,154,154,100)',
        plotShadow: false
      },
      xAxis: {
        categories: times
      },
      yAxis: {
        title: {
          style: {
            color: '#9a9a9a'
          },
          text: 'Sent Messages'
        }
      },
      tooltip: {
        borderColor: 'rgba(0,0,0,0.85)',
        backgroundColor: 'rgba(0,0,0,0.85)',
        style: {
          color: '#9a9a9a'
        },
        crosshairs: true,
        shared: true
      },
      series: [
        {
          name: 'Donkey',
          marker: {
            symbol: 'circle',
            radius: 4
          },
          lineWidth: 4,
          data: 11.times.collect {0} << 12
        },
        {
          name: 'Other',
          marker: {
            symbol: 'circle',
            radius: 4
          },
          lineWidth: 4,
          data: 12.times.collect {0}
        }
      ]
    }.to_json)
    subject.perform(account.id, 'name')
  end
end
