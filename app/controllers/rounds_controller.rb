class RoundsController < ApplicationController
  before_action :set_round, only: %i[edit update destroy]

  def new
    @round = @game_player.rounds.new
  end

  def edit; end

  def create
    @game_player = GamePlayer.find(params[:game_player_id])
    @round = @game_player.rounds.build(round_params)

    if @round.save
      redirect_to game_round_path(@game_player.game, @round), notice: 'Round was successfully created.'
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
end
