collection @opens.map{|open| View::EmailRecipientEvent.new(open, self)}
extends "opens/show"
