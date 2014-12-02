require 'rails_helper'
RSpec.describe NscaStatusWorker, :type => :worker do
  it 'should be OK' do
    worker = NscaStatusWorker.new
    worker.expects(:checks).returns('dummy' => stub('scope', count: 0))
    args = {
      nscahost:    "#{Rails.configuration.datacenter_env}-nagios1.#{Rails.configuration.datacenter_location}.gdi",
      port:        5667,
      hostname:    'xact',
      service:     'dummy',
      return_code: SendNsca::STATUS_OK,
      status:      "Status OK: 0 records"
    }
    SendNsca::NscaConnection.expects(:new).with(args).returns(mock('nsca', send_nsca: true))
    worker.perform
  end

  it 'should be OK' do
    worker = NscaStatusWorker.new
    worker.expects(:checks).returns('dummy' => stub('scope', count: 1))
    args = {
      nscahost:    "#{Rails.configuration.datacenter_env}-nagios1.#{Rails.configuration.datacenter_location}.gdi",
      port:        5667,
      hostname:    'xact',
      service:     'dummy',
      return_code: SendNsca::STATUS_WARNING,
      status:      "Status WARNING: 1 records"
    }
    SendNsca::NscaConnection.expects(:new).with(args).returns(mock('nsca', send_nsca: true))
    worker.perform
  end
end
