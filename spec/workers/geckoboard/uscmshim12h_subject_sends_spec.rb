require 'rails_helper'

describe Geckoboard::Uscmshim12hSubjectSends do
  let(:account){ create(:account_with_sms) }

  subject { Geckoboard::Uscmshim12hSubjectSends.new }
  before do
    @messages = create_list(:email_message, 12, subject: "Donkey", account: account)
  end

  it 'writes sending info for subjects for the past 12 hours in json format to disk' do
    end_time = (Time.now + 1.hour).beginning_of_hour
    start_time = end_time - 12.hours
    time_range = start_time.to_i...end_time.to_i
    times = time_range.step(1.hour).map {|t| Time.at(t).in_time_zone('Eastern Time (US & Canada)').strftime("%H")}

    subject.expects(:write_to_file).with("name.json",{
      chart: {
        type: 'spline'
      },
      title: {
        text: 'Emails by Subject for the past 12 hours'
      },
      xAxis: {
        categories: times
      },
      yAxis: {
        title: {
          text: 'Sent Messages'
        }
      },
      tooltip: {
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
            data: 11.times.collect{0} << 12
        },
        {
            name: "Other",
            marker: {
              symbol: 'circle',
              radius: 4
            },
            lineWidth: 4,
            data: 12.times.collect{0}
        }
      ]
    }.to_json)
    subject.perform(account.id, 'name')
  end
end