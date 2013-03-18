class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json
  self.responder = RablResponder

  before_filter :authenticate_user!
  before_filter :set_default_format
  before_filter :set_page, :only => :index

  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found

  protected

  def set_default_format
    request.format = :json unless params[:format]
  end

  def render_not_found
    render :json=>'{}', :status => :not_found
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
    #binding.pry
    set_link_header(resources.first) if resources.first.respond_to?(:total_pages)
    super
  end
end
