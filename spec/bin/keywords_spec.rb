require 'rails_helper'
require File.expand_path("../../../bin/keywords", __FILE__)

class KeywordsCLI
  no_commands do
    def say(*args)
      # silence!
    end
  end
end

describe KeywordsCLI do
  let(:account) { create(:account_with_sms) }
  let(:keyword_csv) { File.expand_path("../../../test/fixtures/keyword_import.csv", __FILE__) }
  let(:keyword_csv_dup) { File.expand_path("../../../test/fixtures/keyword_import_dup.csv", __FILE__) }

  describe "bulk_create" do
    it "should bulk create" do
      cli = KeywordsCLI.new
      before = account.keywords.count
      cli.bulk_create(account.name, keyword_csv)
      expect(account.keywords.count).to eq(before + 3)
    end

    it "should raise on non-existent bulk_create file" do
      expect{ KeywordsCLI.new.bulk_create(account.name, "LKJLKJLKJ") }.to raise_error(Thor::Error)
    end

    it "should survive a duplicate keyword error" do
      cli = KeywordsCLI.new
      before = account.keywords.count
      cli.bulk_create(account.name, keyword_csv_dup)
      expect(account.keywords.count).to eq(before + 3)
    end
  end
end
