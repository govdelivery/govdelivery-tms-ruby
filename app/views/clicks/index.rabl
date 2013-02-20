collection @clicks.map{|click| View::EmailRecipientEvent.new(click, self)}
extends "clicks/show"
