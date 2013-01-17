require 'active_support'

module Message
  module Status
    NEW = 'new'
    SENDING = 'sending'
    FAILED = 'failed'
    COMPLETED = 'completed'
  end
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    belongs_to :account
    validates_presence_of :account
    before_validation :set_account_from_user

    attr_accessible :recipients_attributes

    has_many :recipients, :dependent => :delete_all, :class_name => self.name.gsub('Message', 'Recipient'), :foreign_key => 'message_id', :order => "#{self.quoted_table_name.gsub(/MESSAGES/i, 'RECIPIENTS')}.created_at DESC"
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

    def sendable_recipients
      recipients.to_send(vendor.id)
    end

    def complete!
      self.completed_at = Time.zone.now
      self.status = Status::COMPLETED
      save!
    end

    def failed!
      self.status = Status::FAILED
      save!
    end

    def sending!
      self.status = Status::SENDING
      save!
    end

    def recipient_counts
      {'total' => recipients.count}.merge(recipient_state_counts)
      # TODO How to handle when recipient creation has been backgrounded and is still running?
      # if (Rails.cache.exist?(CreateRecipientsWorker.job_key(@message.id)) rescue false)
      #   {:message=>'Recipient list is being built and is not yet complete'}
      # else
      #   message.recipients.count
      # end
    end

    protected

    def set_account_from_user
      self.account ||= self.user.account if user
    end

    private

    def recipient_state_counts
      # naive implementation - will probably need to be rolled up or something
      Hash[RecipientStatus.map{ |s| [s, recipients.where(:status => s).count] }]
    end
  end
end
