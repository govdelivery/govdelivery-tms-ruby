class LoadBalancerController < ActionController::API
  def show
    ActiveRecord::Base.connection.select_one('SELECT SYSDATE FROM DUAL')
    render text: 'XACT Donkey Cookies'
  end
end
