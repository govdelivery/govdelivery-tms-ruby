#!/usr/bin/env ruby
require File.expand_path("../../config/environment", __FILE__)
require 'json'

def rolling_hours!(scope, column)
  time_range, timestamp_range = hour_ranges(24)

  results = grouped_by_hour(scope, column, time_range)

  data = zeroes(timestamp_range.step(1.hour)).merge(results).sort_by(&:first)

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
end

def compare_2_rolling_24_hour_periods_by_day!(scope, column)
  time_range, timestamp_range = hour_ranges(48)

  results = grouped_by_hour(scope, column, time_range)

  data = zeroes(timestamp_range.step(1.hour)).
    merge(results).
    sort_by(&:first).
    each_slice(24).
    map{|period| period.map(&:second).sum }.
    reverse # today first

  counts = data.map{|v| {text: '', value: v}}
  puts({item: counts}.to_json)
end

def zeroes(timestamps)
  # start with 0 for every hour
  timestamps.reduce({}){|memo, i|
    # Time objects work as hash keys regardless of time zone (now=Time.now) == now.utc
    memo.merge(Time.at(i) => 0)
  }
end

def grouped_by_hour(scope, column, time_range)
  scope.
    where(created_at: time_range).
    count(group: %Q[trunc(#{scope.quoted_table_name}.#{column}, 'HH24')]) # hash with Time objs as keys
end

def hour_ranges(num_hours)
  # Range's end should be up to but not including one hour from now. This means
  # that part of the range is in the future, which is the desired behavior.
  end_time = (Time.now + 1.hour).beginning_of_hour
  start_time = end_time - num_hours.hours
  time_range = start_time...end_time
  timestamp_range = start_time.to_i...end_time.to_i
  [time_range, timestamp_range]
end

if __FILE__ == $0
  if ARGV[0] == '-d'
    compare_2_rolling_24_hour_periods_by_day!(EmailMessage.where(account_id: 10060), '"CREATED_AT"')
  elsif ARGV[0] == '-c'
    rolling_hours!(EmailRecipientClick.joins(:email_message).where(email_messages: {account_id: 10060}), '"CLICKED_AT"')
  elsif ARGV[0] == '-o'
    rolling_hours!(EmailRecipientOpen.joins(:email_message).where(email_messages: {account_id: 10060}), '"OPENED_AT"')
  else
    rolling_hours!(EmailMessage.where(account_id: 10060), '"CREATED_AT"')
  end
end
