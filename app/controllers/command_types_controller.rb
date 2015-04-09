class CommandTypesController < ApplicationController
  include FeatureChecker
  before_filter :find_user
  feature :sms

  def index
    @command_types = CommandType.all.values
  end
end
