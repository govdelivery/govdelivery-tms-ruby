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


Given(/^the following "(.*?)":$/) do |arg1, table|
    event_types = event_types.hashes.map {|data| data["event_type"]}
    @event_callback_uris = Hash[event_types.map {|event_type| [event_type,nil]}]
end

Then(/^a callback url exists for each "(.*?)"$/) do |arg1, table|
    @event_callback_uris.each_key do |event_type|
        @event_callback_uris[event_type] = @capi.create_callback_uri(event_type)
    end
end

And(/^a callback url is registered for each event_type$/) do 
  puts @event_callback_uris
end

When(/^I send an email message to the magic address of each event state$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the callback registered for each event state should receive a POST referring to the appropriate message$/) do
  pending # express the regexp above with the code you wish you had
end








