require 'rails_helper'

describe IPAWS::StaticResource do
  class StaticResource
    include IPAWS::StaticResource
  end

  before do
    StaticResource.all = []
  end

  describe '.as_json' do
    it 'returns an array of hashes containing all the event code attributes' do
      expect(StaticResource.all.as_json).to be == []
      static_resource = StaticResource.new(
        value: 'VALUE',
        description: 'Static Resource Description',
        cap_exchange: true,
        core_ipaws_profile: false,
        nwem: nil,
        eas_and_public: nil,
        cmas: nil
      )
      expect(static_resource.as_json.keys).to match_array(IPAWS::StaticResource::ATTRIBUTES.map(&:to_s))
    end
  end
end
