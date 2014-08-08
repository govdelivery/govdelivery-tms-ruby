class EmailVendor < ActiveRecord::Base

end

class TmsToOdm < ActiveRecord::Migration
  def up
    EmailVendor.where(worker: 'TmsWorker').each do |v|
      v.update_attribute(:worker, 'OdmWorker')
    end
  end

  def down
  end
end
