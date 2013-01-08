class ActionTypesController < ApplicationController
  before_filter :find_user

  def index
    @action_types = ActionType.all.values
  end
end
