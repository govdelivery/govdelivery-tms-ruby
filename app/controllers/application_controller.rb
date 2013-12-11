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

  before_filter :set_default_format
  before_filter :authenticate
  before_filter :set_page, :only => :index

  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  rescue_from MultiJson::LoadError, :with => :render_malformed_json

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
  # NOTE:
  # authenticate must follow set_default_format to avoid java.lang.NullPointerException
  # at org.apache.tomcat.util.http.parser.HttpParser.parseMediaType
  # this happens when auth_token is invalid
  def authenticate
    authenticate_user!.tap do 
      Rails.logger.info("Authenticated user #{current_user.id} #{current_user.email}")
    end
  end

  def set_default_format
    request.format = :json unless params[:format]
  end

  def render_not_found(e)
    instrument_captured_error(e)
    render :json => '{}', :status => :not_found
  end

  def render_malformed_json(e)
    instrument_captured_error(e)
    render :json => {error: "Something went wrong parsing your request JSON"}, :status => :bad_request
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
    if record = resources.first
      set_link_header(resources.first)       if record.respond_to?(:total_pages)
      log_validation_errors(resources.first) if record.respond_to?(:errors) && !record.errors.empty?
    end
    super
  end

  ##
  # We don't bang-save when using respond_with, so this is the way we get NewRelic
  # to notice there is a problem: give it an exception. 
  #
  def log_validation_errors(r)
    instrument_captured_error(ActiveRecord::RecordInvalid.new(r))
  end

  ## 
  # log something and tell new relic there was a problem somewhere (XACT-213)
  #
  def instrument_captured_error(e)
    # http://rdoc.info/github/newrelic/rpm/NewRelic/Agent:notice_error
    Rails.logger.error e.message
    NewRelic::Agent.notice_error(e)
  end
end
