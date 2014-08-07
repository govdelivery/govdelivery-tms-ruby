# Even when requiring AR and Rails, using explicit requires is 3x faster than
# just `require 'rails_helper'`
require 'spec_helper'
require 'sidekiq'
require 'active_record'
require 'rails'
require_relative '../../app/models/keyword'
require_relative '../../app/workers/forward_stops_to_dcm'

describe ForwardStopsToDcm do
  context '.should_forward?' do
    let(:body) { 'asdf' }
    context 'when body is a stop request' do
      before do
        Keyword.expects(:stop?).at_least_once.with(body).returns(true)
      end

      it 'returns true ONLY if "To" number is in shared_phone_numbers' do
        Rails.stubs(:configuration).returns(stub(:shared_phone_numbers => ['+15554443333']))
        subject.class.should_forward?('Body' => body, 'To' => '+15554443333').should be true
        subject.class.should_forward?('Body' => body, 'To' => '+15554443330').should be false
      end
    end

    it 'retruns false when body is not a stop request' do
      Keyword.expects(:stop?).at_least_once.with(body).returns(false)
      Rails.stubs(:configuration).returns(stub(:shared_phone_numbers => ['+15554443333']))
      subject.class.should_forward?('Body' => body, 'To' => '+15554443333').should be false
      subject.class.should_forward?('Body' => body, 'To' => '+15554443330').should be false
    end
  end

  context '#perform' do
    let (:conn) { mock('Faraday connection') }
    before do
      subject.stubs(:connection).returns(conn)
    end

    it 'uses Faraday connection correctly' do
      Rails.stubs(:configuration).returns(stub(
        dcm: [{api_root: 'a-url'}, {api_root: 'another-url'}],
        shared_phone_numbers: ['+15554443333']
      ))

      conn.expects(:post).with('a-url/api/twilio_requests', is_a(Hash))
      conn.expects(:post).with('another-url/api/twilio_requests', is_a(Hash))
      subject.perform({})
    end
    it 'always sends "stop" as the body param' do
      Rails.stubs(:configuration).returns(stub(
        dcm: [api_root: 'a-url'],
        shared_phone_numbers: ['+15554443333']
      ))

      conn.expects(:post).with('a-url/api/twilio_requests', has_entry('Body', 'stop'))
      Rails.stubs(:configuration).returns(stub(dcm: [api_root: 'a-url'], shared_phone_numbers: ['+15554443333']))
      subject.perform({'Body' => 'subscribe'})
    end
  end
end
