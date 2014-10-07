class ChangeVendorHelpText < ActiveRecord::Migration
  def change
    change_column :sms_vendors, :help_text, :string, null: false, default: "This service is provided by GovDelivery. If you are a customer in need of assistance, please contact customer support."
    SmsVendor.where(name: "Go to http://bit.ly/govdhelp for help").update_all(help_text: "This service is provided by GovDelivery. If you are a customer in need of assistance, please contact customer support.")
  end
end