class VoiceMessagesController < MessagesController
  before_filter :set_attr

  def index
    @messages = current_user.voice_messages.page(@page)
    super
  end

  def new
    @message = current_user.voice_messages.build
    super
  end

  def show
    @message = current_user.voice_messages.find_by_id(params[:id])
    super
  end

  def create
    super
  end

  def set_attr
    @content_attribute = :url
  end
end