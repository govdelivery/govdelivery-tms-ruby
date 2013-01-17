Xact::Application.routes.draw do

  require 'sidekiq/web'
  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end


  devise_for :users, :skip => :all

  # call this to add pagination to your controller
  # e.g.
  # pageable =>
  # paged_messages GET    /messages/page/:page(.:format)                        messages#index
  def pageable
    get 'page/:page', :action => :index, :on => :collection
  end

  resources(:keywords, :only => [:index, :show, :create, :update, :destroy]) do
    resources(:commands, :only => [:index, :show, :create, :update, :destroy], :controller => :keyword_commands)
  end

  scope :messages, :path=>'messages' do
    resources(:email, :only => :create, :controller => :emails)

    resources(:sms, :only => [:index, :new, :create, :show], :controller => :sms_messages) do
      pageable
      resources(:recipients, :only => [:index, :show]) do
        pageable
      end
    end

    resources(:voice, :only => [:index, :new, :create, :show], :controller => :voice_messages) do
      pageable
      resources(:recipients, :only => [:index, :show]) do
        pageable
      end
    end
  end

  scope :inbound, :path=>'inbound', :as=>'inbound' do
    resources(:sms, :only => [:index, :show], :controller => :inbound_messages) do
      pageable
    end
  end

  root :to => 'services#index'
  get 'load_balancer' => 'load_balancer#show'
  get 'command_types' => 'command_types#index'
  post 'twilio_requests' => 'twilio_requests#create'
  post 'twilio_status_callbacks' => 'twilio_status_callbacks#create'
  post 'twiml' => 'twilio_dial_plan#show', :defaults => {:format => 'xml'}
end
