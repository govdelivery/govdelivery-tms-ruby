require 'rails_helper'

describe CommandActionsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get('keywords/100/commands/100/actions')).to route_to('command_actions#index', keyword_id: '100', command_id: '100')
      expect(get('inbound/sms/100/command_actions')).to route_to('command_actions#index', sms_id: '100')
    end

    it 'routes to #show' do
      expect(get('keywords/100/commands/100/actions/1')).to route_to('command_actions#show', id: '1', keyword_id: '100', command_id: '100')
      expect(get('inbound/sms/100/command_actions/1')).to route_to('command_actions#show', id: '1', sms_id: '100')
    end
  end
end
