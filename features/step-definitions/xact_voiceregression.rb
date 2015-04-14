#!/bin/env ruby
# encoding: utf-8

require 'colored'
require 'json'
require 'awesome_print'
require 'twilio-ruby'
require 'httpi'
require 'pry'
require 'faraday'
require 'base64'
require 'multi_xml'
require 'pry'

#================2237 VOICE tests===============>
#================2237 VOICE tests===============>
#================2237 VOICE tests===============>
#================2237 VOICE tests===============>

def phone_number
  '+16123145807'
end

def phone_number_2
  '+16124679346'
end

def voice_message
  {
    1 => 'http://xact-webhook-callbacks.herokuapp.com/voice/first.mp3',
    2 => 'http://xact-webhook-callbacks.herokuapp.com/voice/second.mp3',
    3 => 'http://xact-webhook-callbacks.herokuapp.com/voice/third.mp3',
    4 => 'http://xact-webhook-callbacks.herokuapp.com/voice/fourth.mp3',
    5 => 'http://xact-webhook-callbacks.herokuapp.com/voice/fifth.mp3',
    6 => 'http://xact-webhook-callbacks.herokuapp.com/voice/sixth.mp3',
    7 => 'http://xact-webhook-callbacks.herokuapp.com/voice/seventh.mp3',
    8 => 'http://xact-webhook-callbacks.herokuapp.com/voice/eighth.mp3',
    9 => 'http://xact-webhook-callbacks.herokuapp.com/voice/ninth.mp3',
    10 => 'http://xact-webhook-callbacks.herokuapp.com/voice/tenth.mp3'
  }
end

def random
  rand(1...10)
end

def twiliomation
  # Get your Account Sid and Auth Token from twilio.com/user/account
  account_sid = 'AC189315456a80a4d1d4f82f4a732ad77e'
  auth_token = '88e3775ad71e487c7c90b848a55a5c88'
  @client = Twilio::REST::Client.new account_sid, auth_token
end

Given(/^I created a new voice message$/) do
  @message = client.voice_messages.build(play_url: voice_message[random]) # combine methods where 'random' selects the hash key at random
end

Then(/^I should be able to verify that multiple recipients have received the message$/) do
  @message.recipients.build(phone: phone_number)
  @message.recipients.build(phone: phone_number_2) # change phone
  STDOUT.puts @message.errors unless @message.post
  if @message.response.status == 201
    puts '201 Created'.green
  else
    raise 'Message was not created'.red
  end
end

Then(/^I should be able to verify the statuses using good numbers$/) do
  @message.recipients.build(phone: phone_number)
  STDOUT.puts @message.errors unless @message.post
  if @message.response.status == 201
    puts '201 Created'.green
  else
    raise 'Message was not created'.red
  end
end

Then(/^I should be able to verify the incoming message was received$/) do
  @message = client.voice_messages.get

  sleep(2)

  if @message.collection[random].attributes.include?(:play_url)
    puts 'Play url found'.green
  else
    raise 'Play url was not found'.red
  end

  if @message.collection[random].attributes.include?(:status)
    puts 'Status found'.green
  else
    raise 'Status was not found'.red
  end

  if @message.collection[random].attributes.include?(:created_at)
    puts 'Created at found'.green
  else
    raise 'Created at was not found'.red
  end

  if @message.collection[random].attributes[:play_url].nil?
    raise 'Play url was not found'.red
  end

  if @message.collection[random].attributes[:created_at].nil?
    raise 'Play url was not found'.red
  end

  if @message.collection[random].attributes[:status].nil?
    raise 'Play url was not found'.red
  end
end

Then(/^I should be able to verify the retries and expiration time$/) do
  pending # express the regexp above with the code you wish you had
end

# Given(/^I created a new voice message with too many characters in the play url$/) do
#   @message = client.voice_messages.build(:play_url => 'http://www.longurlmaker.com/go?id=loftylingering7NanoRef152600EasyURLoutstretched1Doiop63eURLPie005s99c75spread%2Bout08NotLongbURLvi53MooURLlongishB650100101eEzURL7sdrawn%2Boutt001201FwdURLShortenURLaA2N11dq210eprotracted114GetShortydeepspun%2Bout713iGetShortyoutstretched2EzURLstretchSitelutionslingeringURLPieDigBiglongish01sustainedexpandedTinyLink0t31continued3tall16longish201stretch9lengthy48DecentURL01019ffprolongeddrawn%2Boutlingeringgangling0619c9GetShorty5Shrinkr9spread%2Bouthighlnk.inbn2lengthy4301URLa11g4GetShorty7ShortURL11612stretchingShrinkrX.se76f5stretching2stretch2espread%2Bout90kA2N3b6cenlarged4EzURLe47750221high9939ShrinkURLan8far%2Boffx6URL00026URL34enlargedtallqA2Nspread%2BoutDwarfurlnm8URLvi78n240StartURL7ganglingTinyURL1Minilien5U76024ct1NotLongb02deep6ue1d0uaf0EasyURLrSmallr3loftyDecentURLj02x3Is.gdB65150rj1spread%2Bout00running45greatz04YATUCganglingSHurl301URL2DigBig51Dwarfurlexpanded3541expanded90931p80enduringURLcut073tally8ShortURL14distantUlimit77dj01024xBeam.tot9d16c11ShortenURL6369Redirx14enduring16r7bShredURLSmallrlnk.instretching009bFly2far%2Breaching1MetamarkRubyURL4prolongedrremote001TraceURL9stretching10SimURLco0longish7SHurlB65Shim8URLCutter404cSitelutionsSimURL0continuedbEasyURLm8Shrtndhf0URLHawk1prolonged15lasting2h011ShortURL190Ulimit05ShortURLenduringsustaineddEasyURLTinyLink401stretch7lengthyy0Beam.toelongatedXilfMooURL2alingeringzadistant7ShortURLdrawn%2Bout9zexpanded1stretching95017spun%2Bout746running01sustainedstretchoefgangling0xnxa11q8r8801FwdURLlanky8spread%2Boutd6a4loftyRedirx192EzURL9034URLCutterb18516URL0dv3f5i1lengthenedhighNe1671oNe1a0tallShrtnd04Smallr41ShoterLinkdrawn%2BoutURLPie5912ShoterLinkvstringy5far%2BreachinggDigBigf16Beam.tof0deep9agNotLonge6protractedremoteb0prolongedt02x03talllengthyShrinkURLc1continuedprolongedebIs.gdrangy60428spread%2BoutNutshellURLganglingt08sustained0TightURL14outstretched6stretch8a971drawn%2Bout0cA2NlTinyLinkdrawn%2Bout1LiteURL0distantstretching527u5nMetamarkURLPie0lanky3lengthenedlankyShortURL9drawn%2BoutShortenURL0a1distant302301URLrunning6a1URLCutter7100Ulimitlongish11gaiShoterLink81fRubyURL0011T')
# end

# Then(/^I should be able to verify that an error is received$/) do
#   @message.recipients.build(:phone => phone_number)
#     # binding.pry
#   STDOUT.puts @message.errors unless @message.post

#   if @message.response.status == 500
#     puts 'error found'.green
#   else
#     raise 'error not found'.red
#   end
# end

Then(/^I should be able to verify details of the message$/) do
  @message.recipients.build(phone: phone_number)
  STDOUT.puts @message.errors unless @message.post
  sleep(10)

  voice = @message.get
  # binding.pry

  if voice.response.body['_links'].include?('recipients')
    puts 'Recipients found'.green
  else
    raise 'Recipients was not found'.red
  end

  if voice.response.body['_links'].include?('failed')
    puts 'Failed found'.green
  else
    raise 'Failed was not found'.red
  end

  if voice.response.body['_links'].include?('self')
    puts 'Self found'.green
  else
    raise 'Self was not found'.red
  end

  if voice.response.body['_links'].include?('sent')
    puts 'Sent found'.green
  else
    raise 'Sent was not found'.red
  end

  if voice.response.body['_links'].include?('human')
    puts 'Human found'.green
  else
    raise 'Human was not found'.red
  end

  if voice.response.body['_links'].include?('machine')
    puts 'Machine found'.green
  else
    raise 'Machine was not found'.red
  end

  if voice.response.body['_links'].include?('busy')
    puts 'Busy found'.green
  else
    raise 'Busy was not found'.red
  end

  if voice.response.body['_links'].include?('no_answer')
    puts 'No Answer found'.green
  else
    raise 'No Answer was not found'.red
  end

  if voice.response.body['_links'].include?('could_not_connect')
    puts 'Cound not connect found'.green
  else
    raise 'Could not connect was not found'.red
  end

  if voice.response.body['recipient_counts'].include?('total')
    puts 'Total found'.green
  else
    raise 'Total was not found'.red
  end

  if voice.response.body['recipient_counts'].include?('new')
    puts 'New found'.green
  else
    raise 'New was not found'.red
  end

  if voice.response.body['recipient_counts'].include?('sending')
    puts 'Sending found'.green
  else
    raise 'Sending was not found'.red
  end

  if voice.response.body['recipient_counts'].include?('inconclusive')
    puts 'Inconclusive found'.green
  else
    raise 'Inconclusive was not found'.red
  end

  if voice.response.body['recipient_counts'].include?('blacklisted')
    puts 'Blacklisted found'.green
  else
    raise 'Blacklisted was not found'.red
  end

  if voice.response.body['recipient_counts'].include?('canceled')
    puts 'Canceled found'.green
  else
    raise 'Canceled was not found'.red
  end

  if voice.response.body['recipient_counts'].include?('sent')
    puts 'Sent found'.green
  else
    raise 'Sent was not found'.red
  end

  if voice.response.body['recipient_counts'].include?('failed')
    puts 'Failed found'.green
  else
    raise 'Failed was not found'.red
  end
end
