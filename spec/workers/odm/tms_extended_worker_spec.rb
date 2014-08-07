require 'rails_helper'
if defined?(JRUBY_VERSION)

  describe Odm::TmsExtendedWorker do
    let(:worker) { Odm::TmsExtendedWorker.new }
    
    it 'should parse recipient ids without erroring on non-integer' do
      worker.parse_recipient_id("234234-l").should eq(nil)
      worker.parse_recipient_id("123").should eq(123)
    end

    it 'should find recipient without error' do
      raiser = mock; raiser.expects(:find).raises(ActiveRecord::RecordNotFound)
      ok = mock; ok.expects(:find).returns(:ok)

      worker.find_recipient('333', raiser).should eq(nil)
      worker.find_recipient('444', ok).should eq(:ok)
    end
  end
end
