class ConvertVendorIsVoiceToEnum < ActiveRecord::Migration
  def up
    add_column(:vendors, :vtype, :string, :limit => 30)
    Vendor.all.each do |v|
      if v.worker == 'LoopbackMessageWorker'
        v.vtype= v.name =~/SMS/ ? :sms : :voice
        puts "setting #{v.name} type to #{v.vtype}"
      else
        puts "setting #{v.name} type to #{v.worker.constantize.vendor_type}"
      end
      v.save!
    end
  end

end
