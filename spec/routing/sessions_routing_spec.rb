require 'rails_helper'

describe 'devise' do
  describe 'routing' do
    it 'routes to #create' do
      expect(get: '/session/new').to route_to(format: :json, controller: "sessions", action: "new")
    end

    it 'routes to #destroy' do
      expect(delete: '/session/destroy').to route_to(format: :json, controller: "sessions", action: "destroy")
    end
  end
end
