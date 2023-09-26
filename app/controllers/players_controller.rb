class PlayersController < ApplicationController
  before_action :set_player, only: %i[show edit update destroy]

  # GET /players or /players.json
  def index
    @sort = params[:sort] || Player.default_sort_column
    @sort_dir = params[:sort_dir] || Player.default_direction

    @players = Player.all.sort_table(@sort, @sort_dir)
    @pagy, @players = pagy(@players)
  end

  # GET /players/1 or /players/1.json
  def show; end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit; end

  # POST /players or /players.json
  def create
    @player = Player.new(player_params)

    if @player.save
      redirect_to player_url(@player), notice: 'Player was successfully created.'
    else
      flash.now[:notice] = @player.errors.map(&:message).join(' ')
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /players/1 or /players/1.json
  def update
    if @player.update(player_params)
      redirect_to player_url(@player), notice: 'Player was successfully updated.'
    else
      flash.now[:notice] = @player.errors.map(&:message).join(' ')
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /players/1 or /players/1.json
  def destroy
    @player.destroy

    respond_to do |format|
      format.html { redirect_to players_url, notice: 'Player was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:name)
  end
end
