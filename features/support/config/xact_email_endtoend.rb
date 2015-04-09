# Config info for the accounts that are used to test email_endtoend

configatron.accounts.email_endtoend.xact.url = configatron.xact.url
email_endtoend = configatron.accounts.email_endtoend

# Common or default values for Email End-to-End test accounts across environments
email_endtoend.xact.user.password             = 'retek01!'
email_endtoend.xact.user.admin                = false

email_endtoend.sms                             = configatron.sms_vendors.loopback.clone
email_endtoend.voice                           = configatron.voice_vendors.loopback.clone
email_endtoend.sms.prefix                      = 'email_end_to_end'

email_endtoend.gmail.imap.address             = 'imap.gmail.com'
email_endtoend.gmail.imap.port                = 993
email_endtoend.gmail.imap.password            = 'govdel01!'
email_endtoend.gmail.imap.enable_ssl          = true

case environment
when :development
  email_endtoend.xact.account.id            = ENV['XACT_EMAILENDTOEND_ACCOUNT_ID']
  email_endtoend.xact.user.token            = ENV['XACT_EMAILENDTOEND_USER_TOKEN']
  email_endtoend.xact.user.email_address    = 'development-email_end_to_end-test@govdelivery.com'

when :qc
  email_endtoend.xact.account.id            = '10541'
  email_endtoend.xact.user.token            = 'LLovBHFaaNY2buT3PxxbCPszaANkywDh'
  email_endtoend.xact.user.email_address    = 'qc-email_end_to_end-test@govdelivery.com'
  email_endtoend.gmail.imap.user_name       = 'canari11dd@gmail.com'

when :integration
  email_endtoend.xact.account.id            = '10243'
  email_endtoend.xact.user.token            = 'NqSCMTYEewtqNNbMNG7pbs6hZPYy3RyM'
  email_endtoend.xact.user.email_address    = 'integration-email_end_to_end-test@govdelivery.com'
  email_endtoend.gmail.imap.user_name       = 'canari9dd@gmail.com'

when :stage
  email_endtoend.xact.account.id            = '10940'
  email_endtoend.xact.user.token            = 'aNYMWXsgqeppQyqGFKPqWLenEFBqAWZ5'
  email_endtoend.xact.user.email_address    = 'stage-email_end_to_end-test@govdelivery.com'
  email_endtoend.gmail.imap.user_name       = 'canari7dd@gmail.com'

when :prod
  email_endtoend.xact.user.email_address    = 'CUKEPROD@govdelivery.com'
  email_endtoend.xact.user.password         = 'GovDel01'
  email_endtoend.gmail.imap.user_name       = 'canari8dd@gmail.com'
end
