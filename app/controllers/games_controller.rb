class GamesController < ApplicationController
  # GET /games/new
  def new
    respond_to do |format|
      format.js
      format.html { redirect_to root_url }
    end
  end
end
