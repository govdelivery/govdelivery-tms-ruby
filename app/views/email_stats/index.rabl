collection @events.map{|event| View::EmailRecipientEvent.new(event, self)}
extends "email_stats/show"
