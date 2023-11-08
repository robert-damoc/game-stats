class GamesController < ApplicationController
  before_action :set_game, only: %i[edit update destroy]

  def index
    @sort = params[:sort] || Game.default_sort_column
    @sort_dir = params[:sort_dir] || Game.default_direction

    @games = Game.includes(:rounds, :game_players).all.sort_table(@sort, @sort_dir)
    @pagy, @games = pagy(@games)
  end

  def show
    @game = Game.includes(:players, game_players: :rounds).find(params[:id])
    player_total_score
  end

  def new
    @game = Game.new
  end

  def edit
    player_total_score
  end

  def create
    @game = Game.new(create_game_params)

    if @game.save
      redirect_to games_url, notice: 'Game was successfully created.'
    else
      flash.now[:notice] = @game.errors.map(&:message).join(' ')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @game.update(update_game_params)
      if params[:page]
        redirect_to games_url(page: params[:page]), notice: 'Game was successfully updated.'
      else
        redirect_to game_url(@game), notice: 'Game was successfully updated.'
      end
    else
      flash.now[:notice] = @game.errors.map(&:message).join(' ')
      @game.reload
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game.game_players.destroy_all
    @game.destroy
    redirect_to games_url, notice: 'Game was successfully destroyed.'
  end

  private

  def set_game
    @game = Game.includes(:players).find(params[:id])
  end

  def create_game_params
    params.require(:game).permit(player_ids: [])
  end

  def update_game_params
    if @game.state_created?
      params.require(:game).permit(:state, player_ids: [], game_players_attributes: %i[id position])
    else
      params.require(:game).permit(:state)
    end
  end

  def player_total_score
    @player_totals = {}

    @game.game_players.each do |player|
      total_score = @game.rounds.sum do |round|
        player_scores = round.scores || {}
        player_scores[player.id.to_s].to_i
      end

      @player_totals[player.id] = total_score
    end
  end
end
