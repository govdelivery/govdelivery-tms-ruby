if $servlet_context.blank?
  puts "Not running inside Tomcat; jobs in app/workers/scheduler won't run"
else
  require 'app/workers/scheduler/schedules'

  if Rails.configuration.odm_polling_enabled
    require 'app/workers/scheduler/odm'
  else
    puts "ODM polling is disabled"
  end

  if Rails.configuration.twilio_polling_enabled
    require 'app/workers/scheduler/twilio'
  else
    puts "Twilio polling is disabled"
  end

end