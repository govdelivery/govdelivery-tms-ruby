class DataMigrationCreateSpecialKeywords < ActiveRecord::Migration
  def up
    username = Rails.configuration.database_configuration[ Rails.env ]["username"]
    exec_insert_account_keywords(username)
    exec_insert_vendor_keywords(username)
  end

  # these are cartesian product queries which feed the insert command
  # so that any special keywords that should exist but don't get inserted
  # - Jesse
  def exec_insert_account_keywords username
    execute "insert into #{username}.keywords
  select #{username}.keywords_seq.nextval,
    ACCOUNT_ID,
    NAME,
    sys_extract_utc(systimestamp),
    sys_extract_utc(systimestamp),
    VENDOR_ID,
    null,
    null,
    name
    from (select *
            from (select 'Keywords::AccountStop' as name from dual
                   union all
                  select 'Keywords::AccountHelp' as name from dual
                   union all
                  select 'Keywords::AccountDefault' as name from dual),
         (select id as vendor_id from #{username}.sms_vendors),
         (select id as account_id from #{username}.accounts)) x
  where not exists (select 1
                      from #{username}.keywords k
                     where x.name = k.name
                       and x.vendor_id = k.vendor_id
                       and x.account_id = k.account_id)"
  end

  def exec_insert_vendor_keywords(username)
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
            from (select 'Keywords::VendorStop' as name from dual
                   union all
                  select 'Keywords::VendorHelp' as name from dual
                   union all
                  select 'Keywords::VendorDefault' as name from dual),
         (select id from #{username}.sms_vendors)) x
  where not exists (select 1
                      from #{username}.keywords k
                     where x.name = k.name
                       and x.id = k.vendor_id)"
  end

end
