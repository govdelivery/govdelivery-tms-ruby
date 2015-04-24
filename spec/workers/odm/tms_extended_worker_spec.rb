require 'rails_helper'
if defined?(JRUBY_VERSION)
  describe Odm::TmsExtendedWorker do
    let(:worker) {Odm::TmsExtendedWorker.new}

    it 'should parse recipient ids without erroring on non-integer' do
      expect(worker.parse_recipient_id('234234-l')).to eq(nil)
      expect(worker.parse_recipient_id('123')).to eq(123)
    end

    it 'should find recipient without error' do
      raiser = mock
      ok = mock
      raiser.expects(:find).raises(ActiveRecord::RecordNotFound)
      ok.expects(:find).returns(:ok)
      expect(worker.find_recipient('333', raiser)).to eq(nil)
      expect(worker.find_recipient('444', ok)).to eq(:ok)
    end
  end
end
