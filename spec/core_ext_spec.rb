require 'spec_helper'

describe GovDelivery::TMS::CoreExt do

  subject do
    Object.new.extend(described_class)
  end

  describe '#camelize' do
    it 'should return camilized string' do
      expect(subject.camelize('sms_message')).to eq 'SmsMessage'
    end
  end

end
