
tms = configatron.tms

case environment
  when :qc
    tms.account_code = 'CUKEAUTO_QC'
    tms.topic_code = 'CUKEAUTO_QC_SMS'
    tms.from_email = 'cukeautoqc@govdelivery.com'
    tms.url = 'https://qc-tms.govdelivery.com/accounts'
    tms.api_root = 'https://qc-tms.govdelivery.com'
  when :integration
    tms.account_code = 'CUKEAUTO_INT'
    tms.topic_code = 'CUKEAUTO_INT_SMS'
    tms.from_email = 'cukeautoint@govdelivery.com'
    tms.url = 'https://int-tms.govdelivery.com/accounts'
    tms.api_root = 'https://int-tms.govdelivery.com'
  when :stage
    tms.account_code = 'CUKEAUTO_STAGE'
    tms.topic_code = 'CUKEAUTO_STAGE_SMS'
    tms.from_email = 'cukestage@govdelivery.com'
    tms.url = 'https://stage-tms.govdelivery.com/accounts'
    tms.api_root = 'https://stage-tms.govdelivery.com'
  when :prod
    tms.api_root = 'https://tms.govdelivery.com'
end

# Admin (Super User)
case environment
  when :qc
    tms.admin.token = '4TvzJZtjAQ8fhaFP6HyFCseq8t7GptSu'
    tms.admin.id = 10100
    tms.admin.email = 'cukeautoqc@govdelivery.com'
    tms.account.id = 10120
    tms.account.errors_to = 'cukeautoqc-errors@govdelivery.com'
  when :integration
    tms.admin.token = 'weppMSnAKp33yi3zuuHdSpN6T2q17yzL'
    tms.admin.id = 10060
    tms.admin.email = 'cukeautoint@govdelivery.com'
    tms.account.id = 10060
    tms.account.errors_to = 'cukeautoint-errors@govdelivery.com'
  when :stage
    tms.admin.token = 'Ub7r7CzbzkkSEmF9iVjYSGi98VLgq3qD' #id: 10440, account_id: 10360, email: "cukestage@govdelivery.com", e
    tms.admin.id = 10440
    tms.admin.email = 'cukestage@govdelivery.com'
    tms.account.id = 10360
    tms.account.errors_to = 'cukestage-errors@govdelivery.com'
end

# NON Admin (not super user)
case environment
  when :qc
    tms.non_admin.token = '2nUnEBWJ362at369KLqgdzR1gGp6meQo'
    tms.non_admin.id = 10460
    tms.non_admin.email = "securitytest@evotest.govdelivery.com"
    tms.non_admin.account_id = 10120
  when :integration
    tms.non_admin.token = 'qJ71WByLHx53Z296Lpkxs9LcCVU6x2gh'
    tms.non_admin.id = 10320
    tms.non_admin.email = 'cuke-user-int@evotest.govdelivery.com'
    tms.non_admin.account_id = 10060
  when :stage
    tms.non_admin.token = 'pzYSpUsoFXx6GKX7jzoQbstsMDyb9f6X'
    tms.non_admin.id = 11320
    tms.non_admin.email = 'cuke-user-stage@evotest.govdelivery.com'
    tms.non_admin.account_id = 10360
end

# SMS User

case environment
  when :qc
    tms.sms.token = 'yopyxmk8NBnr5sa9dxwgf9sEiXpiWv1z'
    tms.sms.id = 10700
    tms.sms.email = 'sms_receiver@evotest.govdelivery.com'
    tms.sms.account_id = 10660
    tms.sms.from_phone
  when :integration
    tms.sms.token = 'hycb4FaXB745xxHYEifQNPdXpgrqUtr3'
    tms.sms.id = 10280
    tms.sms.email = 'sms_receiver@evotest.govdelivery.com'
    tms.sms.account_id = 10300
    tms.sms.from_phone = "+6122556225"
  when :stage
    tms.sms.token = 'pt8EuddxvVSnEcSZojYx8TaiDFMCpiz2'
    tms.sms.id = 11180
    tms.sms.email = 'sms_testing@evotest.govdelivery.com'
    tms.sms.account_id = 11060
    tms.sms.from_phone
end