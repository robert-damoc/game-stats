class GamesController < ApplicationController
  before_action :set_game, only: %i[show edit update destroy]

  def index
    @sort = params[:sort] || Game.default_sort_column
    @sort_dir = params[:sort_dir] || Game.default_direction

    @games = Game.includes(:game_players).all.sort_table(@sort, @sort_dir)
    @pagy, @games = pagy(@games)
  end

  def show; end

  def new
    @game = Game.new
  end

  def edit; end

  def create
    @game = Game.new(create_game_params)

    if @game.save
      redirect_to games_url, notice: 'Game was successfully created.'
    else
      flash[:notice] = @game.errors.map(&:message).join(' ')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if update_game_params[:player_ids]
      to_delete = @game.player_ids - update_game_params[:player_ids].to_a
      @game.game_players.where(player_id: to_delete).map(&:destroy!)
    end

    if @game.update(update_game_params)
      redirect_to games_url(page: params[:page]), notice: 'Game was successfully updated.'
    else
      flash[:notice] = @game.errors.map(&:message).join(' ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
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
      params.require(:game).permit(:state, player_ids: [])
    else
      params.require(:game).permit(:state)
    end
  end
end
