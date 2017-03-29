#
# Get newrelic controller instrumentation working with rails-api
# https://github.com/rails-api/rails-api/issues/34
#

class ApplicationController < ActionController::API
  include ActionController::ImplicitRender

  require "new_relic/agent/instrumentation/rails4/action_controller.rb"
  require "new_relic/agent/instrumentation/rails4/errors"

  include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  include SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler
  include Devise::Controllers::SignInOut if Rails.env.test?

  acts_as_token_authentication_handler_for User
  respond_to :json
  self.responder = RablResponder
  prepend_before_filter :extract_token_header

  ##
  # Our authentication routine will:
  # 1. try to log in using a provided auth_token. If the auth token is invalid
  #    the service will return a 401.
  # 2. if no auth token is given, try to log in with basic auth.
  # 3. if post to /session/new with a valid token query param
  #    (ie: /session/new?token=1234abcd), session will be established and stored
  #    via activerecord-session_store in a session table
  #
  # NOTE:
  # authenticate must follow set_default_format to avoid java.lang.NullPointerException
  # at org.apache.tomcat.util.http.parser.HttpParser.parseMediaType
  # this happens when auth_token is invalid

  before_action :set_default_format
  before_action :authenticate_user!
  before_action :set_page, only: :index

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from JSON::ParserError, with: :render_malformed_json

  protected

  def authenticate_entity_from_token!(entity_class)
    # Set the authentication token params if not already present,
    # see http://stackoverflow.com/questions/11017348/rails-api-authentication-by-headers-token
    params_token_name = "#{entity_class.name.singularize.underscore}_token".to_sym
    params_email_name = "#{entity_class.name.singularize.underscore}_email".to_sym
    if token = params[params_token_name].blank? && request.headers[header_token_name(entity_class)]
      params[params_token_name] = token
    end
    if email = params[params_email_name].blank? && request.headers[header_email_name(entity_class)]
      params[params_email_name] = email
    end

    if entity = User.with_token(params[:auth_token])

      # Notice the store option defaults to false, so the entity
      # is not actually stored in the session and a token is needed
      # for every request. That behaviour can be configured through
      # the sign_in_token option.
      sign_in entity, store: SimpleTokenAuthentication.sign_in_token
    end
  end

  ##
  # Pull the X-AUTH-TOKEN header out of the request and put
  # it in the params hash.
  def extract_token_header
    if request.headers['X-AUTH-TOKEN']
      params.merge!(auth_token: request.headers['X-AUTH-TOKEN'])
    end
  end

  def set_default_format
    request.format = :json unless params[:format]
  end

  def render_not_found(e)
    instrument_captured_error(e)
    render json: '{}', status: :not_found
  end

  def render_malformed_json(e)
    instrument_captured_error(e)
    render json: {error: 'Something went wrong parsing your request JSON'}, status: :bad_request
  end

  def render_invalid_record(e)
    instrument_captured_error(e)
    render json: {errors: e.record.errors.messages}, status: :unprocessable_entity
  end

  def find_user
    @account = current_user.account if user_signed_in?
  end

  def set_page
    page = params[:page].to_i
    @page = (page == 0) ? 1 : page
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
      links[:prev] = url_for(ps.merge(param_name => scope.current_page - 1))
    end
    unless scope.last_page?
      links[:next] = url_for(ps.merge(param_name => scope.current_page + 1))
      links[:last] = url_for(ps.merge(param_name => scope.total_pages))
    end

    links.collect { |k, v| %(<#{v}>; rel="#{k}",)}.join('')
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

  def default_url_options
    ActionController::Base.default_url_options
  end

  def transform_links_payload!(attributes)
    return unless attributes[:_links].is_a?(Hash)
    links = attributes.delete(:_links)
    links.each do |key, value|
      attributes["#{key}_id"] = value
    end
  end
end
