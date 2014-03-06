module IPAWS
  class SampleSoapService < OpenStruct

    def initialize(attributes={})
      super({
        getAck: true, 
        getCOGProfile: {
          :cogid => 999, 
          :name => 'IPAWS Training COG', 
          :description => 'Operating Group-IPAWS Training', 
          :categoryName => 'IPAWS-OPEN', 
          :organizationName => 'CIV', 
          :cogEnabled => 'Y',
          :caeAuthorized => 'N',
          :caeCmasAuthorized => 'N',
          :eanAuthorized => 'N',
          :allEventCode => 'N',
          :allGeoCode => 'N',
          :easAuthorized => 'N',
          :cmasAlertAuthorized => 'N',
          :cmamTextAuthorized => 'N',
          :publicAlertAuthorized => 'N',
          :broadcastAuthorized => 'N',
          :email => 'test@email.com',
          :eventCodes => [
              { 'ALL' => 'SVR' },
              { 'ALL' => 'SVS' },
              { 'ALL' => 'EVI' },
              { 'ALL' => 'SPW' },
              { 'ALL' => 'ADR' },
              { 'ALL' => 'AVW' },
              { 'ALL' => 'TOE' },
              { 'ALL' => 'FFW' },
              { 'ALL' => 'FRW' },
              { 'ALL' => 'VOW' },
              { 'ALL' => 'BZW' },
              { 'ALL' => 'CDW' },
              { 'ALL' => 'LAE' },
              { 'ALL' => 'TOR' },
              { 'EAS' => 'CAE' },
              { 'EAS' => 'RWT' }
            ],
          :geoCodes => [{ 'SAME' => '051510' }]
        }
      }.merge(attributes))
    end

  end
end