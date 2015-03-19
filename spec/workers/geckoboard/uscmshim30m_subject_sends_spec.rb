require 'rails_helper'

describe Geckoboard::Uscmshim30mSubjectSends do
  let(:account) { create(:account_with_sms) }
  let(:dbtime) { ActiveRecord::Base.connection.select_value('SELECT cast(sys_extract_utc(systimestamp) as date) - 1/1440 FROM DUAL') }
  subject { Geckoboard::Uscmshim30mSubjectSends.new }

  before do
    @messages = create_list(:email_message, 50, subject: "Donkey", account: account)

    EmailMessage.update_all(created_at: dbtime)
    @messages.each do |message|
      message.created_at = dbtime
      message.save!
    end
  end

  it 'writes sending info for subjects for the past 30 minutes in json format to disk' do
    end_time   = dbtime + 1.minute
    start_time = end_time - 30.minutes
    time_range = start_time.to_i...end_time.to_i
    times      = time_range.step(1.minute).map { |t| Time.at(t).in_time_zone('Eastern Time (US & Canada)').strftime("%M") }

    expected = {
      colors: ["#FCFFF5", "#D1DBBD", "#91AA9D", "#ACF0F2", "#EB7F00", "#54AC92", "#F1B60B", "#097178", "#9E4292", "#9D21D9", "#03DAF7"],
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
        categories: times
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
      series: [
        {
            name: "Donkey",
            marker: {
              symbol: 'circle',
              radius: 4
            },
            lineWidth: 4,
            data: 29.times.collect{0} << 50
        },
        {
            name: "Other",
            marker: {
              symbol: 'circle',
              radius: 4
            },
            lineWidth: 4,
            data: 30.times.collect{0}
        }
      ]
    }
    expect(subject.build_data(account.id, 'name')).to eq expected
  end
end