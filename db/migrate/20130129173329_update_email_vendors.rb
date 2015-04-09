class UpdateEmailVendors < ActiveRecord::Migration
  def change
    change_table :email_vendors do |t|
      t.remove :username
      t.remove :password
    end
    EmailVendor.where(worker: 'OdmWorker').update_all(worker: 'Odm::TmsExtendedSenderWorker')
  end
end
