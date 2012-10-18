require 'spec_helper'

describe Recipient do
  it "can be instantiated" do
    Recipient.new.should be_an_instance_of(Recipient)
  end

  it "can be saved successfully" do
    message = Message.create(:short_body => 'The short body')
    message.recipients.create(:phone => '6515551000').should be_persisted
  end
end