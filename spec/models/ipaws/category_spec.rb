require 'rails_helper'

describe IPAWS::Category do

  describe '.all' do
    it 'returns a list of Categorys' do
      expect(IPAWS::Category.all).to be_present
      IPAWS::Category.all.each do |category| 
        expect(category).to be_instance_of(IPAWS::Category)
      end
    end
  end

  describe '.as_json' do
    it 'returns an array of hashes containing all the event code attributes' do
      expect(IPAWS::Category.all.as_json).to be_present
      IPAWS::Category.all.each do |category|
        expect(category.as_json.keys.map(&:to_sym)).to match_array(IPAWS::StaticResource::ATTRIBUTES)
      end
    end
  end

  it 'has a unique and present value' do
    values = IPAWS::Category.all.map(&:value)
    expect(values).to be == values.uniq
    values.each do |value|
      expect(value).to be_present
    end
  end

  it 'has a unique and present description' do
    descriptions = IPAWS::Category.all.map(&:description)
    expect(descriptions).to be == descriptions.uniq
    descriptions.each do |description|
      expect(description).to be_present
    end
  end

  it 'contains true/false/nil values for :cap_exchange, :core_ipaws_profile, :nwem, :eas_and_public, and :cmas' do
    IPAWS::Category.all.each do |category|
      [:cap_exchange, :core_ipaws_profile, :nwem, :eas_and_public, :cmas].each do |attribute|
        value = category.send(attribute)
        expect([true, false, nil]).to include(category.send(attribute))
      end
    end
  end

end
