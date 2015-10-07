Rails.application.default_url_options =
  if Rails.env.development?
    {host: 'localhost', port: 3000, protocol: "http"}
  elsif Rails.env.test?
    {host: 'test.host'}
  elsif Rails.env.production?
    {host: 'tms.govdelivery.com', protocol: 'https'}
  elsif Rails.env.integration?
    {host: 'int-tms.govdelivery.com', protocol: 'https'}
  else
    {host: "#{Rails.env}-tms.govdelivery.com", protocol: 'https'}
  end