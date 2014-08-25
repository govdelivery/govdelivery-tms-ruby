object false

node :sid do |u|
  @account.sid
end

node(:'_links') do
  @services
end
