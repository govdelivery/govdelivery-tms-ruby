require 'rails_helper'

describe IPAWS::EventCode do
  describe '.all' do
    it 'returns a list of EventCodes' do
      expect(IPAWS::EventCode.all).to be_present
      IPAWS::EventCode.all.each do |event_code|
        expect(event_code).to be_instance_of(IPAWS::EventCode)
      end
    end
  end

  describe '.as_json' do
    it 'returns an array of hashes containing all the event code attributes' do
      expect(IPAWS::EventCode.all.as_json).to be_present
      IPAWS::EventCode.all.each do |event_code|
        expect(event_code.as_json.keys.map(&:to_sym)).to match_array(IPAWS::StaticResource::ATTRIBUTES)
      end
    end
  end

  it 'has a unique value containing three capital letters' do
    values = IPAWS::EventCode.all.map(&:value)
    expect(values).to be == values.uniq
    values.each do |value|
      expect(value).to be_present
      expect(value).to match(/\A[A-Z]{3}\Z/)
    end
  end

  it 'has a unique and present description' do
    descriptions = IPAWS::EventCode.all.map(&:description)
    expect(descriptions).to be == descriptions.uniq
    descriptions.each do |description|
      expect(description).to be_present
    end
  end

  it 'contains true/false/nil values for :cap_exchange, :core_ipaws_profile, :nwem, :eas_and_public, and :cmas' do
    IPAWS::EventCode.all.each do |event_code|
      [:cap_exchange, :core_ipaws_profile, :nwem, :eas_and_public, :cmas].each do |attribute|
        expect([true, false, nil]).to include(event_code.send(attribute))
      end
    end
  end
end
