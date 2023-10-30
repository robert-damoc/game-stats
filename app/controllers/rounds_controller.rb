class RoundsController < ApplicationController
  # before_action :set_game_player
  before_action :set_game
  before_action :set_round, only: [:edit, :update, :destroy]


  def new
    @round = @game.rounds.new
  end

  def edit; end

  def create
    @round = @game.rounds.new(round_params)

    if @round.save
      redirect_to game_path(@game), notice: 'Round was successfully created.'
    else
      render :new
    end
  end

  def update
    player_id = params[:player_id]
    updated_scores = params[:round][:scores]

    current_scores = @round.scores[player_id.to_s] || {}

    current_scores.merge!(updated_scores)

    @round.scores[player_id.to_s] = current_scores

    @game.game_players.each do |game_player|
      player_id = game_player.player_id.to_s
      @round.scores[player_id] ||= { 'score' => 0 }
    end

    if @round.save
      redirect_to game_path(@game), notice: 'Scores updated successfully.'
    else
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

  # def set_game_player
  #   @game_player = GamePlayer.find_by(player_id: params[:player_id], game_id: params[:game_id])
  # end

  def set_game
    @game = Game.find_by(id: params[:game_id])
  end

  def set_round
    @round = @game.rounds.find(params[:id])
  end
end
