require 'spec_helper'

describe Message do
  it "can be instantiated" do
    Message.new.should be_an_instance_of(Message)
  end

  it "can be saved successfully" do
    Message.create(:short_body => 'The short body').should be_persisted
  end
end