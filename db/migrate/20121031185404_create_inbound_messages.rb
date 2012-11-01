class CreateInboundMessages < ActiveRecord::Migration
  def change
    create_table :inbound_messages do |t|
      t.references :vendor
      t.string :from_phone, :limit=>255  
      t.string :body, :limit=>300
      t.timestamps
    end
  end
end
