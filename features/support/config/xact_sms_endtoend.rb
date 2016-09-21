# Config info for the accounts that are used to test sms_endtoend
sms_endtoend = configatron.accounts.sms_endtoend

case environment
when :development
  sms_endtoend.xact.account.id            = ENV['XACT_SMSENDTOEND_ACCOUNT_ID']
  sms_endtoend.xact.token            = ENV['XACT_SMSENDTOEND_USER_TOKEN']
  sms_endtoend.xact.email_address    = 'development-sms_end_to_end-test@govdelivery.com'
when :qc
  sms_endtoend.xact.account.id            = '10524'
  sms_endtoend.xact.token            = 'YbYQcoszgtoyVwVRHzf8J5nq4GxDff9J'
  sms_endtoend.xact.email_address    = 'qc-sms_end_to_end-test@govdelivery.com'
when :integration
  sms_endtoend.xact.account.id            = '10245'
  sms_endtoend.xact.token            = 'e2pyzcxuEajwEmzQZxgEAQ6yxR5cMDur'
  sms_endtoend.xact.email_address    = 'integration-sms_end_to_end-test@govdelivery.com'
when :stage
  sms_endtoend.xact.account.id            = '10942'
  sms_endtoend.xact.token            = 'zyyyNEf4tTUWqqeYPzQMqkaden8CLnpy'
  sms_endtoend.xact.email_address    = 'stage-sms_end_to_end-test@govdelivery.com'
when :mbloxqc 
  sms_endtoend.xact.account.id            = '10740'
  sms_endtoend.xact.token            = 'Us5n21TWaEPmGnPKKpXSzhpfJcmGoqNB'
  sms_endtoend.xact.email_address    = 'mblox_testing@evotest.govdelivery.com'
when :mbloxintegration
  sms_endtoend.xact.account.id            = '10380'
  sms_endtoend.xact.token            = 'pveBXxeHhggFKHiVfSNbFEXBKxpbZznD'
  sms_endtoend.xact.email_address    = 'mblox_testing@evotest.govdelivery.com'
when :mbloxstage
  sms_endtoend.xact.account.id            = '11520'
  sms_endtoend.xact.token            = 'ofwhSbrMMgseDkhzAVbzUU9bCHf2PMyf'
  sms_endtoend.xact.email_address    = 'mblox_testing_stage@evotest.govdelivery.com'
when :mbloxproduction
  #sms_endtoend.xact.account.id            = '10740'
  #sms_endtoend.xact.token            = 'Us5n21TWaEPmGnPKKpXSzhpfJcmGoqNB'
  sms_endtoend.xact.email_address    = 'mblox_testing_production@evotest.govdelivery.com'
end