require 'rails_helper'

describe 'webhooks/show.rabl' do
  let(:webhook) do
    stub('webhook',
         id: 22,
         to_param: '22',
         url: 'http://fail.com',
         event_type: 'failed',
         created_at: Time.now,
         errors: {},
         persisted?: true
    )
  end

  let(:invalid_webhook) do
    stub('webhook',
         id: 22,
         to_param: '22',
         url: 'http://fail.com',
         event_type: 'failed',
         created_at: Time.now,
         errors: {:url => "Can't be blank"},
         persisted?: false
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

  it 'should have errors with invalid webhook' do
    assign(:webhook, invalid_webhook)
    render
    rendered.should be_json_for(webhook).
                      with_attributes(:url, :event_type).
                      with_timestamps(:created_at).
                      with_links('self' => webhooks_path).
                      with_errors
  end


end
