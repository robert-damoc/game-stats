class PlayersController < ApplicationController
  before_action :set_player, only: %i[show edit update destroy]

  def index
    @players = Player.all.order(created_at: :desc)
    @pagy, @players = pagy(@players)
  end

  def show; end

  def new
    @player = Player.new
  end

  def edit; end

  def create
    @player = Player.new(player_params)

    if @player.save
      respond_to do |format|
        format.html { redirect_to players_path, notice: "#{@player.name} was successfully created." }
        format.turbo_stream { flash.now[:notice] = "#{@player.name} was successfully created." }
      end
    else
      flash.now[:notice] = @player.errors.map(&:message).join(' ')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @player.update(player_params)
      respond_to do |format|
        format.html { redirect_to players_path, notice: "#{@player.name} was successfully updated." }
        format.turbo_stream { flash.now[:notice] = "#{@player.name} was successfully updated." }
      end
    else
      flash.now[:notice] = @player.errors.map(&:message).join(' ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @player.destroy

    respond_to do |format|
      format.html { redirect_to players_path, notice: "#{@player.name} was successfully removed." }
      format.turbo_stream { flash.now[:notice] = "#{@player.name} was successfully removed." }
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
