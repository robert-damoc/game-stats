class Player < ApplicationRecord
  include Sortable

  has_many :game_players
  has_many :games, through: :game_players

  validates :name, presence: true, length: { maximum: 30 }
  validate :can_be_part_of_only_one_active_game, on: :create

  def self.allowed_sort_columns
    %w[name]
  end

  def self.default_sort_column
    'name'
  end

  private

  def can_be_part_of_only_one_active_game
    if games.in_progress.exists?
      errors.add(:base, 'A player can only be part of one active game at a time')
    end
  end
end
