require 'rails_helper'

describe IPAWS::ResponseType do

  describe '.all' do
    it 'returns a list of ResponseTypes' do
      expect(IPAWS::ResponseType.all).to be_present
      IPAWS::ResponseType.all.each do |response_type| 
        expect(response_type).to be_instance_of(IPAWS::ResponseType)
      end
    end
  end

  describe '.as_json' do
    it 'returns an array of hashes containing all the event code attributes' do
      expect(IPAWS::ResponseType.all.as_json).to be_present
      IPAWS::ResponseType.all.each do |response_type|
        expect(response_type.as_json.keys.map(&:to_sym)).to match_array(IPAWS::StaticResource::ATTRIBUTES)
      end
    end
  end

  it 'has a unique and present value' do
    values = IPAWS::ResponseType.all.map(&:value)
    expect(values).to be == values.uniq
    values.each do |value|
      expect(value).to be_present
    end
  end

  it 'has a unique and present description' do
    descriptions = IPAWS::ResponseType.all.map(&:description)
    expect(descriptions).to be == descriptions.uniq
    descriptions.each do |description|
      expect(description).to be_present
    end
  end

  it 'contains true/false/nil values for :cap_exchange, :core_ipaws_profile, :nwem, :eas_and_public, and :cmas' do
    IPAWS::ResponseType.all.each do |response_type|
      [:cap_exchange, :core_ipaws_profile, :nwem, :eas_and_public, :cmas].each do |attribute|
        value = response_type.send(attribute)
        expect([true, false, nil]).to include(response_type.send(attribute))
      end
    end
  end

end
