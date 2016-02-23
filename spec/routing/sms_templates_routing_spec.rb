require 'rails_helper'

describe SmsTemplatesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/templates/sms').to route_to('sms_templates#index')
    end

    it 'routes to #show' do
      expect(get: '/templates/sms/1').to route_to('sms_templates#show', uuid: '1')
    end

    it 'routes to #create' do
      expect(post: '/templates/sms').to route_to('sms_templates#create')
    end

    it 'routes to #update' do
      expect(put: '/templates/sms/1').to route_to('sms_templates#update', uuid: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/templates/sms/1').to route_to('sms_templates#destroy', uuid: '1')
    end
  end
end
