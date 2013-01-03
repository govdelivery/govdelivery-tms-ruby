require 'spec_helper'
require File.dirname(__FILE__) + '/../../db/migrate/20130102212552_serialize_existing_action_parameters'

describe SerializeExistingActionParameters do
  let(:account) {
    vendor = Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker')
    account = Account.create(:name => 'account', :vendor => vendor)
  }

  it 'serializes DCM_UNSUBSCRIBE actions' do
    action = UnserializedAction.create!(:params => 'ACME,VANDELAY', :action_type => Action::DCM_UNSUBSCRIBE, :account => account)
    params = action_params_after_migration(action)
    params.should be_a ActionParameters
    Set.new(params.dcm_account_codes).should == Set.new(%w[ACME VANDELAY])
  end

  it 'serializes DCM_SUBSCRIBE actions' do
    action = UnserializedAction.create!(:params => 'ACME:TOPIC_1,TOPIC_2', :action_type => Action::DCM_SUBSCRIBE, :account => account)
    params = action_params_after_migration(action)
    params.should be_a ActionParameters
    Set.new(params.dcm_topic_codes).should == Set.new(%w[TOPIC_1 TOPIC_2])
    params.dcm_account_code.should == 'ACME'
  end

  it 'serializes FORWARD actions' do
    action = UnserializedAction.create!(:params => 'GET http://foo.com', :action_type => Action::FORWARD, :account => account)
    params = action_params_after_migration(action)
    params.should be_a ActionParameters
    params.http_method.should == 'GET'
    params.url.should == 'http://foo.com'
  end

  def action_params_after_migration(action)
    action_id = action.id
    subject.up
    SerializedAction.find(action_id).params
  end
end

class UnserializedAction < ActiveRecord::Base
  DCM_UNSUBSCRIBE = 1 # :params => ActionParameters.new(:dcm_account_codes => ["ACCOUNT_1", "ACCOUNT_2"])
  DCM_SUBSCRIBE   = 2 # :params => ActionParameters.new(:dcm_account_code => ["ACCOUNT_1"], :dcm_topic_codes => ["TOPIC_1", "TOPIC_2"])
  FORWARD         = 3 # :params => ActionParameters.new(:http_method => "POST|GET", :username => "foo", :password => "bar", :url => "https://foobar.com")
  
  self.table_name = 'actions'

  belongs_to :account
  belongs_to :event_handler

  attr_accessible :account, :action_type, :name, :params
end

class SerializedAction < ActiveRecord::Base
  self.table_name = 'actions'
  serialize :params, ActionParameters
end
