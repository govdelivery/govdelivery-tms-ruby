class UsersController < ApplicationController
  before_filter ->(c) { render(status: :forbidden) unless current_user.admin? }

  def index
    @account = Account.find(params[:account_id])
  end
end
