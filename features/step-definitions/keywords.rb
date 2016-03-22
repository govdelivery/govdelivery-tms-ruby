#####################################################
# Given
#####################################################


#####################################################
# When
#####################################################

# @QC-2453
When(/^I create a new keyword with a text response$/) do
  @keyword = TmsClientManager.non_admin_client.keywords.build(name: "160CHARS#{Time.now.to_i.to_s}", response_text: '160CHARS')
  raise @keyword.errors.to_s unless @keyword.post
end

When(/^I attempt to create a reserved keyword (.*)$/) do |keyword|
  pending "Not implemented in development" if dev_not_live?

  @conf = configatron.accounts.sms_2way_subscribe
  @keyword = TmsClientManager.non_admin_client.keywords.build(name: keyword)
  @keyword.post
end

# @QC-2496
When(/^I attempt to create a keyword with a response text over 160 characters$/) do
  @object = TmsClientManager.non_admin_client.keywords.build(name: '162CHARS', response_text: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient...')
  @object.post
end

# @QC-2492
When(/^I create a new forward keyword and command$/) do
  @keyword = TmsClientManager.non_admin_client.keywords.build(name: "forwardy")
  @keyword.post!
  @command = @keyword.commands.build(
    name: "forwardy 1",
    params: {url: 'https://github.com/govdelivery/tms_client/blob/master/Appraisals', http_method: 'get'},
    command_type: :forward)
  @command.post!
  @command.params = {url: 'https://github.com/govdelivery/tms_client/blob/master/Appraisals', http_method: 'post'}
  @command.put!
end

# @QC-2488
When(/^I create a new subscribe keyword and command$/) do
  @keyword = TmsClientManager.non_admin_client.keywords.build(name: "new_keyword")
  @keyword.post!
  @command = @keyword.commands.build(
    name: "new_command",
    params: {dcm_account_code: "#{TmsClientManager.account_code}", dcm_topic_codes: ["#{TmsClientManager.topic_code}"]},
    command_type: :dcm_subscribe)
  @command.post!
end

When(/^I create a new unsubscribe keyword and command$/) do
  @keyword = TmsClientManager.non_admin_client.keywords.build(name: "newish")
  @keyword.post!
  @command = @keyword.commands.build(
    name: "newish unsub",
    params: {dcm_account_codes: ["#{TmsClientManager.account_code}"], dcm_topic_codes: ["#{TmsClientManager.topic_code}"]},
    command_type: :dcm_unsubscribe)
  @command.post!
end

# @QC-2452
When(/^I create a keyword and command with an invalid account code$/) do
  @keyword = TmsClientManager.non_admin_client.keywords.build(name: "xxinvalid")
  @keyword.post!
  @object = @keyword.commands.build(
    name: "xxinvalid",
    params: {dcm_account_code: 'CUKEAUTO_NOPE', dcm_topic_codes: ['CUKEAUTO_BROKEN']},
    command_type: :dcm_subscribe)
  @object.post
end


#####################################################
# Then
#####################################################

Then(/^I should receive an reserved keyword message$/) do
  @output = JSON.parse(@keyword.errors.to_json)
  raise 'Keyword was created erroneously.'.red unless @output.to_s.include?('reserved')
end

Then(/^I should be able to delete the keyword$/) do
  @keyword.delete
end

Then(/^I should be able to delete the (?:forward|subscribe|unsubscribe) keyword$/) do
  @command.delete!
  @keyword.delete!
end


Then(/^I should expect the uuid and the id to be the same for the (.*) template$/) do |type|
  log.info "#{type.capitalize} template id: #{@template.id}"
  log.info "#{type.capitalize} template uuid: #{@template.uuid}"
  raise 'Both id and uuid are not the same' unless @template.id.to_s.eql?(@template.uuid.to_s)
  raise @template.errors.to_s unless @template.delete
end

Then(/^I should not be able to update the (.*) template with "(.*)" uuid$/) do |type, update_uuid|
  @template.uuid = update_uuid
  raise "Template updated successfully when it should not have" if @template.put
end
