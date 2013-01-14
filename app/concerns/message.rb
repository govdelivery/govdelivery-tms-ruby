module Message
  extend ActiveSupport::Concern

  included do
    paginates_per 50

    belongs_to :user
    belongs_to :account
    validates_presence_of :account
    before_validation :set_account_from_user

    attr_accessible :recipients_attributes

    has_many :recipients, :dependent => :delete_all, :class_name => self.name.gsub('Message', 'Recipient'), :foreign_key => 'message_id'
    accepts_nested_attributes_for :recipients

    def vendor
      account.send(self.class.name.gsub('Message', 'Vendor').underscore)
    end

    def worker
      vendor.worker.constantize
    end

    def create_recipients(recipient_params=[])
      recipients << recipient_params.map do |r|
        recipients.create(r.merge(:vendor => self.vendor))
      end
    end

    def process_blacklist!
      #do nothing by default
    end

    def complete!
      self.completed_at = Time.zone.now
      save!
    end

    protected

    def set_account_from_user
      self.account ||= self.user.account if user
    end
  end
end