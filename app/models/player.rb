class Player < ApplicationRecord
  has_many :game_players, -> { order(position: :asc) }, dependent: :destroy, inverse_of: :player
  has_many :games, through: :game_players

  validates :name, presence: true, length: { maximum: 30 }
end
