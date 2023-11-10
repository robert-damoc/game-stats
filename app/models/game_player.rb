class GamePlayer < ApplicationRecord
  belongs_to :game, inverse_of: :game_players
  belongs_to :player, inverse_of: :game_players
  has_many :rounds, dependent: :delete_all

  acts_as_list scope: :game

  def name_with_position
    "##{position} #{player.name}"
  end
end
