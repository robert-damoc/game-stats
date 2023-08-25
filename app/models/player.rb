class Player < ApplicationRecord
  include Sortable

  has_many :game_players, -> { order(position: :asc) }, dependent: nil, inverse_of: :game_players
  has_many :games, through: :game_players

  validates :name, presence: true, length: { maximum: 30 }

  def self.allowed_sort_columns
    %w[name]
  end

  def self.default_sort_column
    'name'
  end
end
