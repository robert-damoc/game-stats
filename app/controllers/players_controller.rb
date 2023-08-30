class PlayersController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_player, only: %i[show edit update destroy]

  def index
    filtered = Player.where('name ILIKE ?', "%#{params[:filter]}%")
    @pagy, @players = pagy(filtered)
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)

    if @player.save
      flash.now[:notice] = 'Player was successfully created.'
      render turbo_stream: [
        turbo_stream.prepend("players", @player),
        turbo_stream.replace(
          "form_player",
          partial: "form",
          locals: { player: Player.new }
        ),
        turbo_stream.replace("notice", partial: "layouts/flash")
      ]
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @player.update(player_params)
      flash.now[:notice] = "Player was successfully updated."
      render turbo_stream: [
        turbo_stream.replace(@player, @player),
        turbo_stream.replace("notice", partial: "layouts/flash")
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @player.destroy

    flash.now[:notice] = "Player was successfully destroyed."
    render turbo_stream: [
      turbo_stream.remove(@player),
      turbo_stream.replace("notice", partial: "layouts/flash")
    ]
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:name)
  end
end
