require 'rails_helper'

describe ForwardStopsToDcm do
  context '.should_forward?' do
    let(:body) {'asdf'}
    context 'when body is a stop request' do
      before do
        Keyword.expects(:stop?).at_least_once.with(body).returns(true)
      end

      it 'returns true ONLY if "To" number is in shared_phone_numbers' do
        Rails.stubs(:configuration).returns(stub(shared_phone_numbers: ['+15554443333']))
        expect(subject.class.should_forward?(body, '+15554443333')).to be true
        expect(subject.class.should_forward?(body, '+15554443330')).to be false
      end
    end

    it 'retruns false when body is not a stop request' do
      Keyword.expects(:stop?).at_least_once.with(body).returns(false)
      Rails.stubs(:configuration).returns(stub(shared_phone_numbers: ['+15554443333']))
      expect(subject.class.should_forward?(body, '+15554443333')).to be false
      expect(subject.class.should_forward?(body, '+15554443330')).to be false
    end
  end

  context '#perform' do
    let(:conn) {mock('Faraday connection')}
    before do
      subject.stubs(:connection).returns(conn)
    end

    it 'uses Faraday connection correctly' do
      Rails.stubs(:configuration).returns(stub(
                                            dcm: {api_root: 'a-url'},
                                            shared_phone_numbers: ['+15554443333']
      ))

      conn.expects(:post).with('a-url/api/twilio_requests', is_a(Hash))
      subject.perform({})
    end
    it 'always sends "stop" as the body param' do
      Rails.stubs(:configuration).returns(stub(
                                            dcm: {api_root: 'a-url'},
                                            shared_phone_numbers: ['+15554443333']
      ))

      conn.expects(:post).with('a-url/api/twilio_requests', has_entry('Body', 'stop'))
      Rails.stubs(:configuration).returns(stub(dcm: {api_root: 'a-url'}, shared_phone_numbers: ['+15554443333']))
      subject.perform('Body' => 'subscribe')
    end
  end
end
