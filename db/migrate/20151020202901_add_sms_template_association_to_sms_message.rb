class AddSmsTemplateAssociationToSmsMessage < ActiveRecord::Migration
  def change
    add_belongs_to  :sms_messages, :sms_template, index: true
  end
end
