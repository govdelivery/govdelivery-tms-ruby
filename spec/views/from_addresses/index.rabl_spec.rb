require 'rails_helper'

describe 'from_addresses/index.rabl' do
  let(:from_addresses) do
    5.times.map do |i|
      stub('from_address',
           id:             22+i,
           to_param:       (22+i).to_s,
           from_email:     'ben@sink.govdelivery.com',
           reply_to_email: 'andrew@sink.govdelivery.com',
           bounce_email:   'bill@sink.govdelivery.com',
           is_default:     false,
           persisted?:     true,
           errors:         [])
    end
  end

  before do
    assign(:from_addresses, from_addresses)
    Rabl::Engine.any_instance.stubs(:url_for).returns('/fake')
    render
    @json = ActiveSupport::JSON.decode(rendered)
  end
  it 'should have one item' do
    rendered.should have_json_type(Array)
    rendered.should have_json_size(5)
  end
end
