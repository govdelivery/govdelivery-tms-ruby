require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe CommandActionsController do

  let(:vendor) { create_sms_vendor }
  let(:account) { create_account(sms_vendor: vendor) }
  let(:inbound_message) { vendor.inbound_messages.create!(body: 'body', from: 'from', vendor: vendor) }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:keyword) { k=account.keywords.new(:name => "HI").tap { |k| k.vendor = vendor }; k.save!; k }
  let(:params) { {dcm_account_code: 'ACME', dcm_topic_codes: ['ACME_1', 'ACME_2']} }
  let(:command) { k = keyword.commands.build(:command_type => :dcm_subscribe, :name => "ALLIGATORZ", params: params); k.account=account; k.save!; k }

  let(:model) { CommandAction }

  let(:command_actions) do
    3.times.collect do |i|
      stub('CommandAction',
           id: 100+i,
           inbound_message_id: 200+i,
           command_id: 300+i,
           command: stub(keyword_id: 400+i),
           response_body: 'http body',
           status: 200,
           content_type: 'text/plain',
           created_at: i.days.ago
      )
    end
  end

  def valid_attributes
    {
      inbound_message_id: inbound_message.id,
      command_id: command.id,
      response_body: 'http body',
      status: 200,
      content_type: 'text/plain',
    }
  end

  before do
    sign_in user
  end

  describe "GET index" do
    it "works with inbound message" do
      command_action = CommandAction.create! valid_attributes
      get :index, sms_id: inbound_message.id
      response.response_code.should eq(200)
      assigns(:parent).should eq(inbound_message)
      assigns(:command_actions).should eq([command_action])
    end
    it "works with command" do
      command_action = CommandAction.create! valid_attributes
      get :index, command_id: command.id, keyword_id: keyword.id
      response.response_code.should eq(200)
      assigns(:parent).should eq(command)
      assigns(:command_actions).should eq([command_action])
    end
  end

  describe "GET show" do
    it "works with inbound message" do
      command_action = CommandAction.create! valid_attributes
      get :show, sms_id: inbound_message.id, id: command_action.to_param
      response.response_code.should eq(200)
      assigns(:parent).should eq(inbound_message)
      assigns(:command_action).should eq(command_action)
    end
    it "works with command" do
      command_action = CommandAction.create! valid_attributes
      get :show, command_id: command.id, keyword_id: keyword.id, id: command_action.to_param
      response.response_code.should eq(200)
      assigns(:parent).should eq(command)
      assigns(:command_action).should eq(command_action)
    end
  end

  it_should_have_a_pageable_index(:command_actions, InboundMessage) do |test|
    {sms_id: test.inbound_message.id}
  end

end
