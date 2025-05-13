class TeamsController < ApplicationController
  layout "core"

  def index
    @teams = Team.all
  end
end