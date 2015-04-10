class CommandTypesController < ApplicationController
  include FeatureChecker
  before_action :find_user
  feature :sms

  def index
    @command_types = CommandType.all.values
  end
end
