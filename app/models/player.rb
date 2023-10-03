class Player < ApplicationRecord
  include Sortable

  has_many :game_players, -> { order(position: :asc) }, dependent: :destroy, inverse_of: :player
  has_many :games, through: :game_players
  has_many :rounds, dependent: :destroy

  validates :name, presence: true, length: { maximum: 30 }

  def self.allowed_sort_columns
    %w[name]
  end

  def self.default_sort_column
    'name'
  end
end
