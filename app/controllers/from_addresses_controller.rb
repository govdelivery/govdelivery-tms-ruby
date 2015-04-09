class FromAddressesController < ApplicationController
  before_action :find_user

  def index
    @from_addresses = @account.from_addresses.page(@page)
    set_link_header(@from_addresses)
    respond_with(@from_addresses)
  end

  def show
    @from_address = @account.from_addresses.find(params[:id])
    respond_with(@from_address)
  end
end
