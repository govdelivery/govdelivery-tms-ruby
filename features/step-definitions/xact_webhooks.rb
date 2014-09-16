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

Given(/^The following event types:$/) do |event_types|
    event_types = event_types.hashes.map {|data| data["event_type"]}
    @event_callback_uris = Hash[event_types.map {|event_type| [event_type,nil]}]
end

Given(/^A callback url exists for each state$/) do
    @event_callback_uris.each_key do |event_type|
        @event_callback_uris[event_type] = @capi.create_callback_uri(event_type)
    end
end

Given(/^A callback url is registered for each event state$/) do
    puts @event_callback_uris
end