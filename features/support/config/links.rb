configatron.encoded_link_prefix =
  case ENV['XACT_ENV']
    when 'qc'
      'http://qc-links.govdelivery.com:80'
    when 'integration'
      'http://int-links.govdelivery.com:80'
    when 'stage'
      'http://stage-links.govdelivery.com:80/track'
    when 'prod'
      'https://odlinks.govdelivery.com'
  end