require 'rails_helper'

describe 'webhooks/show.rabl' do
  let(:webhook) do
    stub('webhook',
         id: 22,
         to_param: '22',
         url: 'http://fail.com',
         event_type: 'failed',
         created_at: Time.now,
         errors: []
    )
  end


  it 'should tells us stuff' do
    assign(:webhook, webhook)
    render
    rendered.should be_json_for(webhook).
                      with_attributes(:url, :event_type).
                      with_timestamps(:created_at).
                      with_links('self' => webhook_path(webhook))
  end


end
