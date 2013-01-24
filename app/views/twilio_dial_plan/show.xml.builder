xml.instruct!
xml.Response do
	xml.Say "Please stand by for an important message."
	xml.Play "#{@message.play_url}"
end