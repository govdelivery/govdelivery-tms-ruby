require 'spec_helper'
describe Analytics::ListenerBase do
  subject { Analytics::ListenerBase.new.wrapped_object }

  before do
   
  end

  ['group_id', 'channel'].each do |thing|
    it "should have #{thing}" do
      expect { subject.send(thing) }.to raise_exception(NotImplementedError)
    end
  end

  it 'should have on_message' do
    expect { subject.on_message(1,2,3) }.to raise_exception(NotImplementedError)
  end

  it 'should call on_message' do
    client         = stub('YaketyYak::Subscriber')
    subject.client = client
    message        = {}
    partition      = 1
    offset         = 1_000

    client.expects(:each_message).yields(message, partition, offset)
    subject.expects(:on_message).with(message, partition, offset)

    subject.listen
  end
end

