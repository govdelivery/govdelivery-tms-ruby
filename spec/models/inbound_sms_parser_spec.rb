require_relative '../../app/models/inbound_sms_parser'
require_relative '../little_spec_helper'

describe InboundSmsParser, '#dispatch!' do

  it 'returns whatever the callable returns' do
    o = Object.new
    subject.text = ''
    subject.dispatch!({'help' => mock(:call => o)}).should be o
  end

  it 'dispatches on keywords' do
    subject.text = 'subscribe news'
    dispatches_on 'subscribe news'
  end

  it 'ignores case' do
    subject.text = 'SUBSCRIBE NEWS'
    dispatches_on 'subscribe news'
  end

  it 'ignores surrounding whitespace' do
    subject.text = " subscribe news \n"
    dispatches_on 'subscribe news'
  end

  it 'dispatches on help when text is "help"' do
    subject.text = 'help'
    dispatches_on 'help'
  end

  it 'dispatches on help when text is empty' do
    subject.text = ''
    dispatches_on 'help'
  end

  it 'dispatches on help if nothing else matches' do
    subject.text = 'nonsense'
    dispatches_on 'help'
  end

  describe 'stop cases' do
    %w(stop quit STOP QUIT sToP qUiT).each do |stop|
      it "is stop if the message body == '#{stop}'" do
        subject.text = stop
        dispatches_on 'stop'
      end

      it 'ignores surrounding whitespace' do
        subject.text = " #{stop} \n"
        dispatches_on 'stop'
      end

      it 'is stop if the first word in the message is "stop"' do
        subject.text = "#{stop} these messages never!"
        dispatches_on 'stop'
      end

      it 'ignores words containing "stop"' do
        subject.text = "dy#{stop}ia"
        dispatches_on 'help'
      end

      it 'ignores words starting with "stop"' do
        subject.text = "#{stop}word"
        dispatches_on 'help'
      end
    end
  end
end

def dispatches_on(name)
  subject.dispatch!({name => mock(:call => nil)})
end
