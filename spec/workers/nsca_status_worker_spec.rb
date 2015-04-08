require 'rails_helper'
RSpec.describe NscaStatusWorker, type: :worker do
  it 'should be OK' do
    worker = NscaStatusWorker.new
    worker.expects(:checks).returns('dummy' => stub('scope', count: 0))
    args = {
      nscahost:    "#{Rails.configuration.datacenter_env}-nagios1.#{Rails.configuration.datacenter_location}.gdi",
      port:        5667,
      hostname:    'xact',
      service:     'dummy',
      return_code: SendNsca::STATUS_OK,
      status:      "Status OK: 0 records",
      password:    Rails.configuration.nsca_password
    }
    SendNsca::NscaConnection.expects(:new).with(args).returns(mock('nsca', send_nsca: true))
    worker.perform
  end

  it 'should be WARNING' do
    worker = NscaStatusWorker.new
    worker.expects(:checks).returns('dummy' => stub('scope', count: 1))
    args = {
      nscahost:    "#{Rails.configuration.datacenter_env}-nagios1.#{Rails.configuration.datacenter_location}.gdi",
      port:        5667,
      hostname:    'xact',
      service:     'dummy',
      return_code: SendNsca::STATUS_WARNING,
      status:      "Status WARNING: 1 records",
      password:    Rails.configuration.nsca_password
    }
    SendNsca::NscaConnection.expects(:new).with(args).returns(mock('nsca', send_nsca: true))
    worker.perform
  end

  %w{datacenter_env datacenter_location nsca_password}.each do |config|
    it "should exit if #{config} is not set" do
      Rails.configuration.stubs(config).returns(nil)
      SendNsca::NscaConnection.expects(:new).never
      expect { NscaStatusWorker.new.perform }.not_to raise_error
    end
  end
end
