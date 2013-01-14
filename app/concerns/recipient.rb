#
# Before saving, recipient tries to properly format the 
# provided phone attribute into the formatted_phone attribute. 
#
# A recipient without a formatted_phone is one that we 
# cannot possibly forward on to the third-party provider. 
#
module Recipient
  extend ActiveSupport::Concern

  included do
    belongs_to :message, :class_name => self.name.gsub('Recipient', 'Message')
    belongs_to :vendor, :class_name => self.name.gsub('Recipient', 'Vendor')

    attr_accessible :message_id, :vendor_id

    def complete!
      raise NotImplementedError.new('implement it')
    end
  end

end
