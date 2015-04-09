require 'ostruct'

class UsersController < ApplicationController
  before_filter lambda { |_c|
    render(json: { error: 'forbidden' },
           status: :forbidden) unless current_user.admin?
  }

  def index
    account_obj = Account.find(params[:account_id])
    @account = account_obj.attributes
    @account['users'] = []
    account_obj.users.each do |user_obj|
      user = user_obj.attributes
      user.delete('encrypted_password')
      user['tokens'] = user_obj.authentication_tokens.map(&:token)
      @account['users'] << user
    end
    @account = OpenStruct.new(@account)
  end
end
