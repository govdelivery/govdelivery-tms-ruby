xml.instruct!
xml.Response do
	xml.Say "Hello user."
	xml.Play "#{@message.url}"
end