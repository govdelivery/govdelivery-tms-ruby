class TmsToOdm < ActiveRecord::Migration
  def up
    EmailVendor.find_all_by_worker('TmsWorker').each do |v|
      v.update_attribute(:worker, 'OdmWorker')
    end
  end

  def down
  end
end
