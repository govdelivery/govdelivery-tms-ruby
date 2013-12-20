#!/usr/bin/env ruby
require File.expand_path("../../config/environment", __FILE__)

now = Time.now.in_time_zone('Eastern Time (US & Canada)')
end_time = (now + 1.hour).beginning_of_hour
start = end_time - 24.hours
date_range=start...end_time
int_range=start.to_i...end_time.to_i

results=EmailMessage.
  where(account_id: 10060).
  where(created_at: date_range).
  count(group: "trunc(created_at, 'HH24')")

# start with 0 for every hour
data=int_range.step(1.hour).reduce({}){|memo, i|
  memo.merge(Time.at(i).utc => 0)
}.merge(results).sort_by(&:first)

counts = data.map(&:second)
max = counts.max
xlabels = data.map{|x| x.first.in_time_zone('Eastern Time (US & Canada)').strftime('%H')}
puts({
  item: counts,
  settings: {
    axisx: xlabels,
    axisy: [0, max/2, max],
    colour: 'ff9900'
  }
}.to_json)
