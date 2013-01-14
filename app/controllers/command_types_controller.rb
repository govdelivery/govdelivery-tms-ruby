class CommandTypesController < ApplicationController
  before_filter :find_user

  def index
    @command_types = CommandType.all.values
  end
end
