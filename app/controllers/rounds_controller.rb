class RoundsController < ApplicationController
  before_action :set_round, only: %i[edit update destroy]

  def new
    @round = Round.new
  end

  def edit; end

  def create
    @game_player = GamePlayer.find(params[:game_player_id])
    @round = @game_player.rounds.build(round_params)

    if @round.save
      redirect_to game_round_path(@game_player.game, @round), notice: 'Round was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @round.update(round_params)
      redirect_to round_url(@round), notice: 'Round was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @round.destroy
    redirect_to rounds_url, notice: 'Round was successfully destroyed.'
  end

  private

  def set_round
    @round = Round.find(params[:id])
  end

  def round_params
    params.require(:round).permit(:game_player_id, :round_type, :position, :scores)
  end
end
