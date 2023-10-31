class RoundsController < ApplicationController
  before_action :set_game
  before_action :set_round, only: %i[edit update destroy]

  def new
    @round = @game.rounds.new
  end

  def edit; end

  def create
    @round = @game.rounds.new(round_params)

    if @round.save
      redirect_to game_path(@game), notice: 'Round was successfully created.'
    else
      flash.now[:notice] = @round.errors.map(&:message).join(' ')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @round.update(round_params)
      redirect_to game_path(@game), notice: 'Scores updated successfully.'
    else
      flash.now[:notice] = @round.errors.map(&:message).join(' ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @round.destroy
    redirect_to game_path(@game), notice: 'Round was successfully destroyed.'
  end

  private

  def round_params
    params.require(:round).permit(:game_player_id, :round_type, scores: {})
  end

  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_round
    @round = @game.rounds.find(params[:id])
  end
end
