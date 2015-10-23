{
  "jakety-jak.zk-connect"                 => Conf.analytics_zookeepers.join(','),
  "jakety-jak.streams-per-topic"          => '10',
  "jakety-jak.max-in-flight-per-stream"   => '128',
  "jakety-jak.commit-interval-seconds"    => '10',
  "jakety-jak.commit-after-message-count" => '10000',
}.each do |property, value|
  java.lang.System.getProperties().setProperty(property, value)
end
# see also: config/application.conf

if (conf = Rails.configuration.analytics) && conf[:enabled]
  require Rails.root.join('app/workers/analytics/bounce_listener')
  require Rails.root.join('app/workers/analytics/click_listener')
  require Rails.root.join('app/workers/analytics/open_listener')
end


