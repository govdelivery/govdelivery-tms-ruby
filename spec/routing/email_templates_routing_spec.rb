require 'rails_helper'

describe EmailTemplatesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/templates/email').to route_to('email_templates#index')
    end

    it 'routes to #show' do
      expect(get: '/templates/email/1').to route_to('email_templates#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/templates/email').to route_to('email_templates#create')
    end

    it 'routes to #update' do
      expect(put: '/templates/email/1').to route_to('email_templates#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/templates/email/1').to route_to('email_templates#destroy', id: '1')
    end
  end
end
