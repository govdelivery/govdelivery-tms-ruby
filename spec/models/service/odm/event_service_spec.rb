require File.expand_path('../../../../../app/models/service/odm/event_service', __FILE__)
require 'spec_helper'

module Service
  module Odm
    describe EventService do
      [:open, :delivery, :click].each do |type|
        it "gives me #{type} events" do
          fetcher = 'YO!'
          sequence = 'STUFF!!!'
          vendor = "I'm a vendor!"
          creds = "I'm credentials!"
          odm_service = "I'm an ODM service!"

          Fetcher.expects(:new).with(type, creds, odm_service).returns(fetcher)
          Sequence.expects(:new).with(type, vendor).returns(sequence)
          EventIterator.expects(:new).with(fetcher, sequence).returns([1,2,3])

          EventService.expects(:credentials).with(vendor).returns(creds)
          EventService.expects(:odm).returns(odm_service)

          events = EventService.send("#{type}_events", vendor)
          expect(events).to eq([1,2,3])
        end
      end
    end
  end
end
