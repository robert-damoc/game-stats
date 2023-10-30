class RoundsController < ApplicationController
  before_action :set_game_and_players
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
      # update_scores

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
    params.require(:round).permit(:game_player_id, :round_type, :position, :scores)
  end

  def set_game_and_players
    @game = Game.find_by(id: params[:game_id])
    @players = @game.player_ids
    @game_players = @game.game_players
  end

  def set_round
    @round = @game.rounds.find(params[:id])
  end

  def update_scores
    @game.players.each do |player|
      updated_scores = params[:scores][player_name]

      current_scores = @round.scores[player.id.to_s] || {}

      if updated_scores.is_a?(String)
        current_scores[player.id] = updated_scores.to_i
        @round.scores[player.id.to_s] = current_scores
      end
    end

    @round.save!
  end
end
