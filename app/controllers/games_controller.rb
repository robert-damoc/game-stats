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
    respond_to do |format|
      if @game.update(game_params)
        if params[:players]
          for player_id in params[:players]
            player = Player.find(player_id)
            if !@game.players.include?(player)
              @game.players << player
            end
          end

          for player in @game.players
            if !params[:players].include?(player.id)
              @game.players.delete(player)
            end
          end
        end
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
end
