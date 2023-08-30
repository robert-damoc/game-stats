class Game < ApplicationRecord
  include Sortable

  MAX_PLAYERS_PER_GAME = 8

  has_many :game_players, dependent: :destroy
  has_many :players, through: :game_players

  enum state: {
    created: 'created',
    in_progress: 'in_progress',
    completed: 'completed',
    canceled: 'canceled'
  }

  def self.allowed_sort_columns
    %w[created_at id state]
  end

  def self.default_sort_column
    'created_at'
  end

  def self.default_direction
    'desc'
  end
end
