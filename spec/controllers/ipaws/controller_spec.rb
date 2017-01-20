require 'rails_helper'

describe IPAWS::Controller, type: :controller do
  let(:user) {create :user, account: create(:account, ipaws_vendor: create(:ipaws_vendor))}

  describe 'a CAP exception that indicates their server is borked' do
    controller do
      def index
        cap            = Java::ServicesIpawsFemaGovIpaws_capservice::CAPServiceException.new
        cap.error_code = '503'
        cap.message    = 'CAPServiceException'
        raise Java::ServicesIpawsFemaGovIpaws_capservice::CAPSoapException.new('everything is terrible', cap)
      end
    end

    it 'should return a 502 error' do
      sign_in user
      get :index, format: :json
      expect(response.code).to eq '502'
      json = JSON.parse(response.body)
      expect(json['error']).to eq('the IPAWS service is not available')
      expect(json['status_code']).to eq '502'
    end
  end

  describe 'a CAP exception that indicates some java problems on our side' do
    controller do
      def index
        raise Java::JavaLang::RuntimeException.new('foo')
      end
    end

    it 'should return a 502 error' do
      sign_in user
      expect do
        get :index, format: :json
      end.to raise_error(RuntimeError)
    end
  end
end