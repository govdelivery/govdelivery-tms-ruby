require 'spec_helper'

if defined? JRUBY_VERSION

  describe IPAWS::AlertsController do

    let(:ipaws_credentials) do
      {
        ipaws_user_id: 12345,
        ipaws_cog_id: 'IPAWS_OPEN_12345',
        ipaws_jks_base64: 'AAAAAAA',
        ipaws_public_password: 'alligator',
        ipaws_private_password: ')W*#$*SLDFJK#H$#'
      }
    end

    # These sample responses were derived directly from the IPAWS spec PDF.

    let(:sample_alert) do
      {
        'identifier' => 'CAP12-TEST-11-30-0001',
        'sender' => 'test@open.com',
        'status' => 'Actual',
        'info' => {
          'language' => 'en-US',
          'category' => 'Safety'
        } 
      }
    end

    let(:sample_post_message_response) do
      {
        'identifier' => 'CAP12-TEST-11-30-0001',
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

    let(:sample_post_message_error_response) do
      {
        'identifier' => 'CAP12-TEST-11-30-0001',
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

    describe "POST create" do

      it 'returns the IPAWS successful response' do
        IPAWSClient.any_instance.stubs(:post_message).returns(sample_post_message_response)
        user = create :user, account: create(:account, ipaws_vendor: create(:ipaws_vendor))
        sign_in user
        post :create, ipaws_credentials.merge(sample_alert)
        response.response_code.should == 200
        expect(response.body).to be_present
        data = JSON.parse(response.body)
        expect(data).to be == sample_post_message_response
      end

      it 'returns the IPAWS error response' do
        IPAWSClient.any_instance.stubs(:post_message).returns(sample_post_message_error_response)
        user = create :user, account: create(:account, ipaws_vendor: create(:ipaws_vendor))
        sign_in user
        post :create, ipaws_credentials.merge(sample_alert)
        response.response_code.should == 200
        expect(response.body).to be_present
        data = JSON.parse(response.body)
        expect(data).to be == sample_post_message_error_response
      end

      it 'responds with 403 (forbidden) if no IPAWS vendor' do
        IPAWSClient.any_instance.stubs(:post_message).returns(sample_post_message_response)
        user = create :user, account: create(:account, ipaws_vendor: nil)
        sign_in user
        post :create, ipaws_credentials.merge(sample_alert)
        response.response_code.should == 403
      end

    end

  end

end