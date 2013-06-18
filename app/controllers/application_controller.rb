#
# Get newrelic controller instrumentation working with rails-api
# https://github.com/rails-api/rails-api/issues/34
#
require "new_relic/agent/instrumentation/rails3/action_controller"
require "new_relic/agent/instrumentation/rails3/errors"

class ApplicationController < ActionController::API
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation
  include NewRelic::Agent::Instrumentation::Rails3::ActionController
  include NewRelic::Agent::Instrumentation::Rails3::Errors
  include ActionController::MimeResponds
  respond_to :json
  self.responder = RablResponder
  prepend_before_filter :extract_token_header

  before_filter :authenticate
  before_filter :set_default_format
  before_filter :set_page, :only => :index

  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found

  # URL helper methods will use this set of options as defaults 
  def default_url_options
    {:protocol => Rails.configuration.protocol}
  end

  protected
  
  ##
  # Pull the X-AUTH-TOKEN header out of the request and put
  # it in the params hash.
  def extract_token_header
    if request.headers['X-AUTH-TOKEN']
      params.merge!({:auth_token => request.headers['X-AUTH-TOKEN']})
    end
  end

  ## 
  # Our authentication routine will: 
  # 1. try to log in using a provided auth_token. If the auth token is invalid
  #    the service will return a 401. 
  # 2. if no auth token is given, try to log in with basic auth.
  #
  def authenticate
    authenticate_user! # devise method
  end

  def set_default_format
    request.format = :json unless params[:format]
  end

  def render_not_found
    render :json=>'{}', :status => :not_found
  end

  def render_not_authorized
    render :json => '{}', :status => :unauthorized
  end

  def find_user
    if user_signed_in?
      @account = current_user.account
    end
  end

  def set_page
    @page = Integer(params[:page]) rescue 1
  end

  def set_link_header(scope)
    # set first, prev, next, last
    response.headers['Link'] = link_header(scope, params)
  end

  def link_header(scope, params)
    links = {}
    param_name = Kaminari.config.param_name
    ps = params.merge(only_path: true, format: nil)
    unless scope.first_page?
      links[:first] = url_for(ps.merge(param_name => 1))
      links[:prev] = url_for(ps.merge(param_name => scope.current_page-1))
    end
    unless scope.last_page?
      links[:next] = url_for(ps.merge(param_name => scope.current_page+1))
      links[:last] = url_for(ps.merge(param_name => scope.total_pages))
    end

    links.collect { |k, v| %Q|<#{v}>; rel="#{k}",| }.join("")
  end

  def respond_with(*resources, &block)
    set_link_header(resources.first) if resources.first.respond_to?(:total_pages)
    super
  end
end
