require 'spec_helper'

describe IPAWS::AlertsController do

  describe "POST create" do

    it 'returns the IPAWS successful response' do
      user = create :user, account: create(:account, ipaws_vendor: create(:ipaws_vendor))
      sign_in user
      attributes = sample_alert_attributes
      post :create, attributes
      response.response_code.should == 200
      expect(response.body).to be_present
      data = JSON.parse(response.body)
      expect(data).to be == IPAWS::SampleSoapService.new.postMessageResponse(attributes[:identifier])
    end

    it 'returns the IPAWS error response' do
      user = create :user, account: create(:account, ipaws_vendor: create(:ipaws_vendor))
      sign_in user
      attributes = sample_invalid_alert_attributes
      post :create, attributes
      response.response_code.should == 200
      expect(response.body).to be_present
      data = JSON.parse(response.body)
      expect(data).to be == IPAWS::SampleSoapService.new.postMessageErrorResponse(attributes[:identifier])
    end

    it 'responds with 403 (forbidden) if no IPAWS vendor' do
      user = create :user, account: create(:account, ipaws_vendor: nil)
      sign_in user
      post :create, sample_alert_attributes
      response.response_code.should == 403
    end

  end

  def sample_alert_attributes
    {
      identifier: 'CAP12-TEST-11-30-0001',
      sender: 'test@open.com',
      status: 'Actual',
      info: {
        language: 'en-US',
        category: 'Safety'
      } 
    }
  end

  def sample_invalid_alert_attributes
    # Add 'error' to the id to trigger an error response by our sample soap service.
    attributes = sample_alert_attributes
    attributes[:identifier] = 'CAP12-ERROR-TEST-11-30-0001'
    attributes
  end

end