if $servlet_context
  require 'app/workers/scheduler/schedule_tms_stats'
else
   puts "Not running inside Tomcat; jobs in app/workers/scheduler won't run"
end