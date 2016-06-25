# Config info for the accounts that are used to test email_endtoend

configatron.accounts.email_endtoend.xact.url      = configatron.xact.url
email_endtoend                                    = configatron.accounts.email_endtoend

# Common or default values for Email End-to-End test accounts across environments
email_endtoend.xact.user.password                 = 'retek01!'
email_endtoend.xact.user.admin                    = false
email_endtoend.xact.user.from_name_two            = 'from_address_level_from_name'


email_endtoend.sms                                = configatron.sms_vendors.loopback.clone
email_endtoend.voice                              = configatron.voice_vendors.loopback.clone
email_endtoend.sms.prefix                         = 'email_end_to_end'

email_endtoend.gmail.imap.address                 = 'imap.gmail.com'
email_endtoend.gmail.imap.port                    = 993
email_endtoend.gmail.imap.password                = 'govdel01!'
email_endtoend.gmail.imap.enable_ssl              = true

case environment
when :development
  email_endtoend.xact.account.id                  = ENV['XACT_EMAILENDTOEND_ACCOUNT_ID']
  email_endtoend.xact.user.token                  = ENV['XACT_EMAILENDTOEND_USER_TOKEN']
  email_endtoend.xact.user.email_address          = 'development-email_end_to_end-test@govdelivery.com'

when :qc
  case site
  when :dc3
    email_endtoend.xact.account.id                = '12345'
    email_endtoend.xact.user.token                = 'token'
    email_endtoend.xact.user.email_address        = 'qc-dc3-email_end_to_end-test@govdelivery.com'
    email_endtoend.gmail.imap.user_name           = 'govdsmokeasqctest@gmail.com'
    email_endtoend.gmail.imap.password            = 'iVtpWJgAQhMVNyWI'
  else
    email_endtoend.xact.account.id                = '10541'
    email_endtoend.xact.user.token                = 'LLovBHFaaNY2buT3PxxbCPszaANkywDh'
    email_endtoend.xact.user.email_address        = 'qc-email_end_to_end-test@govdelivery.com'
    email_endtoend.xact.user.from_address_two     = 'qc-email_end_to_end-test2@govdelivery.com'
    email_endtoend.xact.user.reply_to_address     = 'qcemail_end_to_end-reply@govdelivery.com'
    email_endtoend.xact.user.reply_to_address_two = 'qcemail_end_to_end-reply2@govdelivery.com'
    email_endtoend.xact.user.bounce_address       = 'qc-email_end_to_end-errors@govdelivery.com'
    email_endtoend.xact.user.bounce_address_two   = 'qc-email_end_to_end-errors2@govdelivery.com'
    email_endtoend.gmail.imap.user_name           = 'canari4dd+1@gmail.com'
  end
when :integration
  email_endtoend.xact.account.id                  = '10243'
  email_endtoend.xact.user.token                  = 'NqSCMTYEewtqNNbMNG7pbs6hZPYy3RyM'
  email_endtoend.xact.user.email_address          = 'integration-email_end_to_end-test@govdelivery.com'
  email_endtoend.xact.user.from_address_two       = 'integration-email_end_to_end-test2@govdelivery.com'
  email_endtoend.xact.user.from_name
  email_endtoend.xact.user.reply_to_address       = 'integrationemail_end_to_end-reply@govdelivery.com'
  email_endtoend.xact.user.reply_to_address_two   = 'integrationemail_end_to_end-reply2@govdelivery.com'
  email_endtoend.xact.user.bounce_address         = 'integration-email_end_to_end-errors@govdelivery.com'
  email_endtoend.xact.user.bounce_address_two     = 'integration-email_end_to_end-errors2@govdelivery.com'
  email_endtoend.gmail.imap.user_name             = 'canari4dd+2@gmail.com'
when :stage
  email_endtoend.xact.account.id                  = '10940'
  email_endtoend.xact.user.token                  = 'aNYMWXsgqeppQyqGFKPqWLenEFBqAWZ5'
  email_endtoend.xact.user.email_address          = 'stage-email_end_to_end-test@govdelivery.com'
  email_endtoend.xact.user.from_address_two       = 'stage-email_end_to_end-test2@govdelivery.com'
  email_endtoend.xact.user.reply_to_address       = 'stageemail_end_to_end-reply@govdelivery.com'
  email_endtoend.xact.user.reply_to_address_two   = 'stageemail_end_to_end-reply2@govdelivery.com'
  email_endtoend.xact.user.bounce_address         = 'stage-email_end_to_end-errors@govdelivery.com'
  email_endtoend.xact.user.bounce_address_two     = 'stage-email_end_to_end-errors2@govdelivery.com'
  email_endtoend.gmail.imap.user_name             = 'canari4dd+3@gmail.com'
when :prod
  email_endtoend.xact.account.id                  = '10220'
  email_endtoend.xact.user.email_address          = 'CUKEPROD@govdelivery.com'
  email_endtoend.xact.user.password               = 'GovDel01'
  email_endtoend.xact.user.email_address          = 'production-email_end_to_end-test@govdelivery.com'
  email_endtoend.xact.user.from_address_two       = 'production-email_end_to_end-test2@govdelivery.com'
  email_endtoend.xact.user.reply_to_address       = 'productionemail_end_to_end-reply@govdelivery.com'
  email_endtoend.xact.user.reply_to_address_two   = 'productionemail_end_to_end-reply2@govdelivery.com'
  email_endtoend.xact.user.bounce_address         = 'production-email_end_to_end-errors@govdelivery.com'
  email_endtoend.xact.user.bounce_address_two     = 'production-email_end_to_end-errors2@govdelivery.com'
  email_endtoend.gmail.imap.user_name             = 'canari4dd+4@gmail.com'
  email_endtoend.xact.user.token                  = '7sRewyxNYCyCYXqdHnMFXp8PSvmpLqRW'
end
