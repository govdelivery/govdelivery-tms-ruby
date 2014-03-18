module IPAWS
  class Vendor < ActiveRecord::Base

    self.table_name = 'ipaws_vendors'

    has_many :accounts, foreign_key: :ipaws_vendor_id, inverse_of: :ipaws_vendor

    validates :cog_id, :user_id, :public_password_encrypted, :private_password_encrypted, :jks, presence: true 

    ENCRYPTION_KEY = ENV['ENCRYPTION_KEY'] || "10536b708d56b7219a0fae56c33a5ea77615d212cc75864885ca52cc9051d2062b2cf3f4b79319864cfba503c3f278ba918a5c82c34e599b84d4e9f394ec99a7"

    attr_encrypted :public_password, key: ENCRYPTION_KEY, attribute: :public_password_encrypted
    attr_encrypted :private_password, key: ENCRYPTION_KEY, attribute: :private_password_encrypted

    def client(reload=false)
      @client = nil if reload
      @client ||= begin
        jks_tempfile = Tempfile.new(['ipaws', '.jks'])
        jks_tempfile.write(jks)
        jks_tempfile.close
        IPAWSClient.new(cog_id, user_id, jks_tempfile.path, public_password, private_password)
      end
    end

  end
end