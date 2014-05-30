class AddVendorStartKeyword < ActiveRecord::Migration
  def up
    username = Rails.configuration.database_configuration[ Rails.env ]["username"]
    exec_vendor_start_keyword(username)
  end

  def down
  end

  # these are cartesian product queries which feed the insert command
  # so that any special keywords that should exist but don't get inserted
  # - by Jesse
  def exec_vendor_start_keyword(username)
    execute "insert into #{username}.keywords
  select #{username}.keywords_seq.nextval,
    null,
    NAME,
    sys_extract_utc(systimestamp),
    sys_extract_utc(systimestamp),
    ID,
    null,
    null,
    name
    from (select *
            from (select 'Keywords::VendorStart' as name from dual),
         (select id from #{username}.sms_vendors)) x
  where not exists (select 1
                      from #{username}.keywords k
                     where x.name = k.name
                       and x.id = k.vendor_id)"
  end

end
