require 'rails_helper'

describe LoadBalancerController, 'testing status' do
  before :each do
    @connection = stub('connection')
    ActiveRecord::Base.stubs(:connection).returns(@connection)
  end

  describe 'a happy GET show' do
    it 'should render nothing' do
      @connection.expects(:select_one).with('SELECT SYSDATE FROM DUAL')
      get :show
      expect(response.code).to eq('200')
      expect(response.body).to eq('XACT Donkey Cookies')
    end
  end

  describe 'a sad GET show' do
    it 'should render 500' do
      @connection.expects(:select_one).with('SELECT SYSDATE FROM DUAL').raises(Exception.new('OH GOD'))
      expect {get :show}.to raise_error
    end
  end
end
