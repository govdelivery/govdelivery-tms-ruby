require 'rails_helper'

describe 'from_addresses/show.rabl' do
  let(:from_address) do
    stub('from_address',
         id:             22,
         to_param:       '22',
         from_email:     'ben@sink.govdelivery.com',
         reply_to_email: 'andrew@sink.govdelivery.com',
         bounce_email:   'bill@sink.govdelivery.com',
         is_default:     false,
         persisted?:     true,
         errors:         [])
  end

  it 'should tell us stuff' do
    assign(:from_address, from_address)
    render
    rendered.should be_json_for(from_address).
                      with_attributes(:from_email, :bounce_email, :reply_to_email, :is_default).
                      with_timestamps(:created_at).
                      with_links('self' => from_address_path(from_address))
  end

end
