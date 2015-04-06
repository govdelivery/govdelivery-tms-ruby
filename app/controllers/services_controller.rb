class ServicesController < ApplicationController
  before_filter :find_user

  # root routing does not work as advertised. it should only allow GET
  before_filter ->(c){ render_405 unless request.method == "GET" }

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
      @services[:email_templates] = email_templates_path
      @services[:from_addresses] = from_addresses_path
    end

    if @account.voice_vendor
      @services[:voice_messages] = voice_index_path
      @services[:incoming_voice_messages] = incoming_voice_messages_path
    end

    if @account.ipaws_vendor
      @services[:ipaws_event_codes] = ipaws_event_codes_path
      @services[:ipaws_categories] = ipaws_categories_path
      @services[:ipaws_response_types] = ipaws_response_types_path
      @services[:ipaws_acknowledgement] = ipaws_acknowledgement_path
      @services[:ipaws_cog_profile] = ipaws_cog_profile_path
      @services[:ipaws_nwem_authorization] = ipaws_nwem_authorization_path
      @services[:ipaws_nwem_areas] = ipaws_nwem_areas_path
      @services[:ipaws_alerts] = ipaws_alerts_path
    end

    if current_user.admin?
      @services[:accounts] = accounts_path
    end

    @services[:webhooks] = webhooks_path
  end


  private

  def render_405
    response['Allow'] = 'GET'
    render(json: ["only GET method allowed"], status: 405) and return
  end
end
