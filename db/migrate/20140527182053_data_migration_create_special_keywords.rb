class DataMigrationCreateSpecialKeywords < ActiveRecord::Migration
  def up
    exec_insert_account_keywords
    exec_insert_vendor_keywords
  end

  # these are cartesian product queries which feed the insert command
  # so that any special keywords that should exist but don't get inserted
  # - Jesse
  def exec_insert_account_keywords
    execute "insert into person_xdev.keywords
  select person_xdev.keywords_seq.nextval,
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
         (select id as vendor_id from person_xdev.sms_vendors),
         (select id as account_id from person_xdev.accounts)) x
  where not exists (select 1
                      from person_xdev.keywords k
                     where x.name = k.name
                       and x.vendor_id = k.vendor_id
                       and x.account_id = k.account_id)"
  end

  def exec_insert_vendor_keywords
    execute "insert into person_xdev.keywords
  select person_xdev.keywords_seq.nextval,
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
         (select id from person_xdev.sms_vendors)) x
  where not exists (select 1
                      from person_xdev.keywords k
                     where x.name = k.name
                       and x.id = k.vendor_id)"
  end

end
