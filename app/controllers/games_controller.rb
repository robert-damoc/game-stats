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
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to game_url(@game), notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        flash[:notice] = @game.errors.map(&:message).join(' ')
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1 or /games/1.json
  def update
    if @game.state_created?
      to_delete = @game.player_ids - update_params[:player_ids]
      @game.game_players.where(player_id: to_delete).map(&:destroy!)
    end

    respond_to do |format|
      if @game.update(update_params)
        format.html { redirect_to game_url(@game), notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        flash[:notice] = @game.errors.map(&:message).join(' ')
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1 or /games/1.json
  def destroy
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_game
    @game = Game.includes(:players).find(params[:id])
  end

  def game_params
    params.require(:game).permit(:state, player_ids: [])
  end

  def update_params
    if @game.state_created?
      game_params
    else
      params.require(:game).permit(:state)
    end
  end
end
