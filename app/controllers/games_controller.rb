class GamesController < ApplicationController
  before_action :set_game, only: %i[show edit update destroy]

  # GET /games or /games.json
  def index
    @sort = params[:sort] || Game.default_sort_column
    @sort_dir = params[:sort_dir] || Game.default_direction

    @games = Game.all.sort_table(@sort, @sort_dir)
    @pagy, @games = pagy(@games)
  end

  # GET /games/1 or /games/1.json
  def show; end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit; end

  # POST /games or /games.json
  def create
    @game = Game.new(create_game_params)

    if @game.save
      redirect_to game_url(@game), notice: 'Game was successfully created.'
    else
      flash[:notice] = @game.errors.map(&:message).join(' ')
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /games/1 or /games/1.json
  def update
    if @game.state_created?
      to_delete = @game.player_ids - update_game_params[:player_ids].to_a
      @game.game_players.where(player_id: to_delete).map(&:destroy!)
    end

    case params[:commit]
    when 'Start Game'
      if @game.state == 'created'
        if @game.player_ids.count.between?(Game::MIN_PLAYERS_PER_GAME, Game::MAX_PLAYERS_PER_GAME)
          @game.update(state: 'in_progress')
        else
          redirect_to @game, notice: 'Game must have between 2 and 8 players to start.'
          return
        end
      end
    when 'Cancel Game'
      @game.update(state: 'canceled') if @game.state == 'in_progress' || @game.state == 'created'
    when 'Complete Game'
      @game.update(state: 'completed') if @game.state == 'in_progress'
    end

    if @game.update(update_game_params)
      redirect_to game_url(@game), notice: 'Game was successfully updated.'
    else
      flash[:notice] = @game.errors.map(&:message).join(' ')
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /games/1 or /games/1.json
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
      create_game_params
    else
      params.require(:game).permit(:state, players_ids: [])
    end
  end
end
