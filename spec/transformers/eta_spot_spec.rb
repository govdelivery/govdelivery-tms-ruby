require 'spec_helper'
require_relative '../../app/transformers/eta_spot'

describe Transformers::EtaSpot do
  let(:valid_json) { {get_stop_etas: [{smsText: "Blah"}]}.to_json }
  let(:invalid_json) { "test" }
  let(:valid_format) { "application/json" }
  let(:invalid_format) { "text/plain" }

  context "with a valid payload" do
    context "and an invalid format" do
      subject do
        Transformers::EtaSpot.new(valid_json, invalid_format)
      end

      it 'should not have an acceptable format' do
        expect(subject.acceptable_format?).to be(false)
      end

      it 'should raise an error on transform transformed' do
        expect { subject.transform }.to raise_error(Transformers::InvalidResponse, "invalid content type: text/plain")
      end
    end

    context "and a valid format" do
      subject do
        Transformers::EtaSpot.new(valid_json, valid_format)
      end

      it 'should have an acceptable format' do
        expect(subject.acceptable_format?).to be(true)
      end

      it 'should return an the smsText when returning the transformed data' do
        expect(subject.transform).to eq("Blah")
      end
    end
  end

  context "with an invalid payload" do
    context "and invalid format" do
      subject do
        Transformers::EtaSpot.new(invalid_json, invalid_format)
      end

      it 'should not have an acceptable format' do
        expect(subject.acceptable_format?).to be(false)
      end

      it 'should return an empty string when returning the transformed data' do
        expect { subject.transform }.to raise_error(Transformers::InvalidResponse, "invalid content type: text/plain")
      end
    end

    context "and a valid format" do
      subject do
        Transformers::EtaSpot.new(invalid_json, valid_format)
      end

      it 'should have an acceptable format' do
        expect(subject.acceptable_format?).to be(true)
      end

      it 'should return an empty string when returning the transformed data' do
        expect { subject.transform }.to raise_error(Transformers::InvalidResponse, "got invalid response body 'test'")
      end
    end
  end
end
