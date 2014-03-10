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
        }.stringify_keys
      }.merge(attributes))
    end

    def postMessage(attributes)
      id = attributes['identifier'] || attributes[:identifier] || ''
      if id =~ /error/i
        postMessageErrorResponse(id)
      else
        postMessageResponse(id)
      end
    end

    def postMessageResponse(id)
      { 
        'identifier' => id,
        'responses' => [
          {
            'CHANNELNAME' => 'CAPEXCH',
            'STATUSITEMID' => 200,
            'ERROR' => 'N',
            'STATUS' => 'Ack'
          },
          {
            'CHANNELNAME' => 'IPAWS',
            'STATUSITEMID' => 300,
            'ERROR' => 'N',
            'STATUS' => 'Ack'
          },
          {
            'CHANNELNAME' => 'CAPEXCH',
            'STATUSITEMID' => 200,
            'ERROR' => 'N',
            'STATUS' => 'Ack'
          },
          {
            'CHANNELNAME' => 'NWEM',
            'STATUSITEMID' => 400,
            'ERROR' => 'N',
            'STATUS' => 'Ack'
          },
          {
            'CHANNELNAME' => 'EAS',
            'STATUSITEMID' => 500,
            'ERROR' => 'N',
            'STATUS' => 'Ack'
          },
          {
            'CHANNELNAME' => 'CMAS',
            'STATUSITEMID' => 600,
            'ERROR' => 'N',
            'STATUS' => 'Ack'
          },
          {
            'STATUSITEMID' => 801,
            'ERROR' => 'N',
            'STATUS' => 'message-not-disseminated-as-non-EAS-public'
          }
        ]
      }
    end

    def postMessageErrorResponse(id)
      { 
        'identifier' => id,
        'responses' => [
          {
            'CHANNELNAME' => 'IPAWS',
            'STATUSITEMID' => 307,
            'ERROR' => 'Y',
            'STATUS' => 'reference-element-invalid'
          }
        ]
      }
    end

  end
end