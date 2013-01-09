class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json
  self.responder = RablResponder

  before_filter :authenticate_user!
  before_filter :set_default_format

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
    links = {}
    unless scope.first_page?
      links[:first] = page_link(1)
      links[:prev] = page_link(scope.current_page-1)
    end
    unless scope.last_page?
      links[:next] = page_link(scope.current_page + 1)
      links[:last] = page_link(scope.total_pages)
    end

    # set first, prev, next, last
    response.headers['Link'] = links.collect { |k, v| %Q|<#{v}>; rel="#{k}",| }.join("")
  end

  def page_link(page)
    opts = {:only_path=>true}
    opts[:page] = page if page
    url_for(opts)
  end
end
