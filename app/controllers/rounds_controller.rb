class RoundsController < ApplicationController
  before_action :set_round, only: %i[edit update destroy]
  before_action :set_game_player

  def new
    @round = @game_player.rounds.new
  end

  def edit
    @round = @game_player.rounds.find(params[:id])
  end

  def create
    @round = @game_player.rounds.new(round_params)

    if @round.save
      redirect_to game_path(@game_player.game), notice: 'Round was successfully created.'
    else
      render :new
    end
  end

  def update
    @round = @game_player.rounds.find(params[:id])

    if @round.update(round_params)
      redirect_to game_path(@game_player.game), notice: 'Round was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @round = @game_player.rounds.find(params[:id])
    @round.destroy

    redirect_to game_path(@game_player.game), notice: 'Round was successfully destroyed.'
  end

  private

  def set_round
    @round = Round.find(params[:id])
  end

  def round_params
    params.require(:round).permit(:game_player_id, :round_type, :position, :scores)
  end

  def set_game_player
    @game_player = GamePlayer.find_by(player_id: params[:player_id], game_id: params[:game_id])
  end

  def set_game
    @game = @game_player.game if @game_player
  end
end
