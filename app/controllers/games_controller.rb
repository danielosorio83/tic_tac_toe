class GamesController < ApplicationController
  before_action :setup_game

  # GET /games/new
  def new
    respond_to do |format|
      format.js
      format.html { redirect_to root_url }
    end
  end

  # PUT /game
  def update
    @game.update(permitted_params(:update))
  end

  private

  def setup_game
    @game = Game.new(params[:size])
  end

  def permitted_params(action = :create)
    params.permit(:player, :position, table: [])
  end
end
