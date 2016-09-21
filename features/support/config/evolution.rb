# Configatron for interacting with the evo api.

evo = configatron.evolution


case environment
  when :qc
    evo.account.email_address = 'autocukeqc_sa@evotest.govdelivery.com'
    evo.account.password = 'govdel01!'
    evo.api_url = 'https://qc-api.govdelivery.com/api/account/CUKEAUTO_QC/subscribers/'
  when :integration
    evo.account.email_address = 'autocukeint_sa@evotest.govdelivery.com'
    evo.account.password = 'govdel01!'
    evo.api_url = 'https://int-api.govdelivery.com/api/account/CUKEAUTO_INT/subscribers/'
  when :stage
    evo.account.email_address = 'autocukestage_sa@evotest.govdelivery.com'
    evo.account.password = 'govdel01!'
    evo.api_url = 'https://stage-api.govdelivery.com/api/account/CUKEAUTO_STAGE/subscribers/'
  when :prod
    evo.account.email_address = 'autocukeprod_sa@evotest.govdelivery.com'
    evo.account.password = 'govdel01!'
    evo.api_url = 'https://api.govdelivery.com/api/account/CUKEAUTO_PROD/subscribers/'
end