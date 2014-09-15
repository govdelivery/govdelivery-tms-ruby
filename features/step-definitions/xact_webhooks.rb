def env
    if ENV['XACT_ENV'] == 'qc'
        client = TMS::Client.new('auth_token', :api_root => 'https://stage-tms.govdelivery.com')
    elsif ENV['XACT_ENV'] == 'int'
        "http://int-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'stage'
        "http://stage-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'prod'
        "http://tms.govdelivery.com"
    end
end

def url
    if ENV['XACT_ENV'] == 'qc'
        "http://qc-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'int'
        "http://int-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'stage'
        "http://stage-tms.govdelivery.com"
    elsif ENV['XACT_ENV'] == 'prod'
        "http://tms.govdelivery.com"
    end
end

When(/^placeholder$/) do
  "#{env}"
  webhook = client.webhooks.build(:url=>"#{url}", :event_type=>'inconclusive')
  webhook.post
end

Then(/^something$/) do
  puts 'Arby\'s nation.'
end

When(/^The following event types:$/) do |event_types|
    event_types = event_types.hashes.map {|data| data["event_type"]}
    @event_callbacks = Hash[event_types.map {|event_type| [event_type,nil]}]
end

When(/^A callback url exists for each state$/) do
    puts @event_callbacks
end