module IPAWS
  class Vendor < ActiveRecord::Base

    self.table_name = 'ipaws_vendors'

    has_many :accounts, foreign_key: :ipaws_vendor_id, inverse_of: :ipaws_vendor

    validates :cog_id, :user_id, :encrypted_public_password, :encrypted_private_password, :jks, presence: true 

    ENCRYPTION_KEY = ENV['ENCRYPTION_KEY'] || "10536b708d56b7219a0fae56c33a5ea77615d212cc75864885ca52cc9051d2062b2cf3f4b79319864cfba503c3f278ba918a5c82c34e599b84d4e9f394ec99a7"

    attr_encrypted :public_password, key: ENCRYPTION_KEY, attribute: :encrypted_public_password
    attr_encrypted :private_password, key: ENCRYPTION_KEY, attribute: :encrypted_private_password

    def client(reload=false)
      @client = nil if reload
      @client ||= begin
        jks_tempfile = Tempfile.new('ipaws_jks')
        jks_tempfile.write(jks)
        IPAWSClient.new(cog_id, user_id, jks_tempfile.path, public_password, private_password)
      ensure
        if jks_tempfile
          jks_tempfile.close 
          jks_tempfile.unlink
        end
      end
    end

  end
end