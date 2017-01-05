require 'rails_helper'

describe Service::SmsBody do
  it 'should prefix messages with the env by default' do
    expect(Service::SmsBody.annotated('foo')).to eq ('[test] foo')
  end

  it 'should not prefix messages when disabled' do
    Rails.configuration.expects('non_prod_message_annotations').returns(false)
    expect(Service::SmsBody.annotated('foo')).to eq ('foo')
  end
end
