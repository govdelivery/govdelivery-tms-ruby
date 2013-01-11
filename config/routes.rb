Tsms::Application.routes.draw do

  require 'sidekiq/web'
  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end


  devise_for :users, :skip => :all

  # call this to add pagination to your controller
  # e.g.
  # pageable('messages') =>
  # paged_messages GET    /messages/page/:page(.:format)                        messages#index
  def pageable(controller)
    collection do
      get 'page/:page' => "#{controller}#index", :as => :paged
    end
  end

  resources(:keywords, :only => [:index, :show, :create, :update, :destroy])

  scope :messages, :path=>'messages' do
    resources(:email, :only => :create, :controller => :emails)

    resources(:sms, :only => [:index, :new, :create, :show], :controller => :sms_messages) do
      pageable('sms_messages')
      resources(:recipients, :only => [:index, :show]) do
        pageable('recipients')
      end
    end

    resources(:voice, :only => [:index, :new, :create, :show], :controller => :voice_messages) do
      pageable('voice_messages')
      resources(:recipients, :only => [:index, :show]) do
        pageable('recipients')
      end
    end
  end

  scope :inbound, :path=>'inbound', :as=>'inbound' do
    resources(:sms, :only => [:index, :show], :controller => :inbound_messages) do
      pageable('inbound_messages')
    end
  end

  root :to => 'services#index'
  get 'load_balancer' => 'load_balancer#show'
  get 'action_types' => 'action_types#index'
  post 'twilio_requests' => 'twilio_requests#create'
  post 'twilio_status_callbacks' => 'twilio_status_callbacks#create'
  post 'twiml' => 'twilio_dial_plan#show', :defaults => {:format => 'xml'}
end
