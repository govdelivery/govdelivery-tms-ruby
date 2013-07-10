class ServicesController < ApplicationController
  before_filter :find_user

  # root routing does not work as advertised. it should only allow GET
  before_filter ->(c){ render(json: ["only GET method allowed"], status: 400) and return unless request.method == "GET" }

  def index
    @services = { :self => root_path }

    if @account.sms_vendor
      @services[:keywords] = keywords_path
      @services[:command_types] = command_types_path 
      @services[:inbound_sms_messages] = inbound_sms_index_path 
      @services[:sms_messages] = sms_index_path 
    end

    if @account.email_vendor
      @services[:email_messages] = email_index_path
    end

    if @account.voice_vendor
      @services[:voice_messages] = voice_index_path
    end
  end
end
