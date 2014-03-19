module IPAWS
  class Vendor < ActiveRecord::Base

    self.table_name = 'ipaws_vendors'

    has_many :accounts, foreign_key: :ipaws_vendor_id, inverse_of: :ipaws_vendor

    validates :cog_id, :user_id, :public_password_encrypted, :private_password_encrypted, :jks, presence: true 

    attr_encrypted :public_password, attribute: :public_password_encrypted
    attr_encrypted :private_password, attribute: :private_password_encrypted

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