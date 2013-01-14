class ServicesController < ApplicationController
  before_filter :find_user

  def index
    @services = [{ :self => root_path }]

    if @account.sms_vendor
      @services << {:keywords => keywords_path}
      @services << {:command_types => command_types_path }
      @services << {:inbound_sms => inbound_sms_index_path }
      @services << {:sms_messages => sms_index_path }
    end

    if @account.email_vendor
      @services << {:emails => email_index_path}
    end

    if @account.voice_vendor
      @services << {:voice_messages => voice_index_path}
    end
  end
end
