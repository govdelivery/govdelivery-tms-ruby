require File.dirname(__FILE__) + '/../spec_helper'

describe LoadBalancerController, "testing status" do
  before :each do 
    @connection = double("connection")
    ActiveRecord::Base.stub(:connection){ @connection }
  end

  describe "a happy GET show" do
    it "should render nothing" do
      @connection.should_receive(:select_one).with('SELECT SYSDATE FROM DUAL')
      get :show
      response.code.should == "200"
    end
  end
  
  describe "a sad GET show" do
    it "should render 500" do
      @connection.should_receive(:select_one).with('SELECT SYSDATE FROM DUAL') do 
        raise Exception.new("OH GOD")
      end
      expect { get :show }.to raise_error
    end
  end
end
