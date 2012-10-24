class MessagesController < ApplicationController
  before_filter :find_user
  before_filter :set_page, :only => :index

  def index
    @messages = current_user.messages.page(@page)
    set_link_header(@messages)
    respond_with(@message)
  end

  def show
    @message = current_user.messages.find_by_id(params[:id])
    respond_with(@message)
  end

  def create
    recipients = params[:message].delete(:recipients) if params[:message]
    @message = current_user.messages.new(params[:message])
    if @message.save
      recipients.each { |recipient| @message.recipients.create(recipient) } if recipients
      current_user.vendor.worker.constantize.send(:perform_async, @message.id)
    end
    respond_with(@message)
  end

  private
  def set_link_header(scope)
    links = {}
    unless scope.first_page?
      links[:first] =  page_link(1)
      links[:prev] =  page_link(scope.current_page-1)
    end
    unless scope.last_page?
      links[:next] = page_link(scope.current_page + 1)
      links[:last] = page_link(scope.total_pages)
    end

    # set first, prev, next, last
    response.headers['Link'] = links.collect{|k,v| %Q|<#{v}>; rel="#{k}",|}.join("")
  end

  def page_link(page)
    if page==1
      messages_path
    else
      paged_messages_path(page)
    end
  end

  def set_page
    @page = params[:page] || 1
  end

end
