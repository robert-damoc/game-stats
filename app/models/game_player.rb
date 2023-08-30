class GamePlayer < ApplicationRecord
  belongs_to :game
  belongs_to :player

  acts_as_list scope: :game

  def name_with_position
    "##{position} #{player.name}"
  end
end
