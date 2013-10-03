# encoding: UTF-8
require File.expand_path('../../spec_helper', __FILE__)

describe InboundSmsParser, '#dispatch!' do

  it 'returns whatever the callable returns' do
    o = Object.new
    subject.text = ''
    subject.dispatch!({'help' => mock(:call => o)}).should be o
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

  describe 'keywords' do
    it 'should dispatch with variables' do
      subject.text = " Subscribe  foo@bar.com\n"
      lamb = mock
      lamb.expects(:call).with('foo@bar.com')
      subject.dispatch!('subscribe' => lamb)
    end

    it 'should dispatch on non-ascii chars' do
      subject.text = " SÜSCRÍBÁSÉÑ  foo@bar.com\n"
      lamb = mock
      lamb.expects(:call).with('foo@bar.com')
      subject.dispatch!('süscríbáséñ' => lamb)
    end
  end

  describe 'stop cases' do
    %w(stop quit STOP QUIT sToP qUiT cancel unsubscribe).each do |stop|
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

def dispatches_on(name, lamb=nil)
  lamb ||= mock(:call => nil)
  subject.dispatch!({name => lamb})
end
