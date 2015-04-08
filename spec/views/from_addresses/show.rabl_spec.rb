require 'rails_helper'

describe 'from_addresses/show.rabl' do
  let(:account) { create(:account) }
  let(:from_address) { account.default_from_address }

  it 'should tell us stuff' do
    assign(:from_address, from_address)
    render
    expect(rendered).to be_json_for(from_address).
                      with_attributes(:from_email, :bounce_email, :reply_to_email, :is_default).
                      with_timestamps(:created_at).
                      with_links('self' => from_address_path(from_address))
  end

end
