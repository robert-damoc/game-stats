class Game < ApplicationRecord
  include Sortable

  MAX_PLAYERS_PER_GAME = 8
  MIN_PLAYERS_PER_GAME = 2
  VALID_TRANSITIONS = {
    created: %i[created in_progress canceled],
    in_progress: %i[in_progress completed canceled],
    completed: %i[completed],
    canceled: %i[canceled]
  }.freeze

  validate :valid_state_transition, on: :update
  validates :game_players, length: {
    maximum: MAX_PLAYERS_PER_GAME,
    message: "There can be a maximum of #{MAX_PLAYERS_PER_GAME} players in a game."
  }
  validates :game_players, length: {
    minimum: MIN_PLAYERS_PER_GAME,
    message: "Minimum number of players to start the game is #{MIN_PLAYERS_PER_GAME}"
  }, if: -> { state_in_progress? }

  has_many :game_players, -> { order(position: :asc) }, dependent: :destroy, inverse_of: :game
  has_many :players, through: :game_players

  enum state: {
    created: 'created',
    in_progress: 'in_progress',
    completed: 'completed',
    canceled: 'canceled'
  }, _prefix: true

  def can_start?
    state_created? && game_players.count.between?(MIN_PLAYERS_PER_GAME, MAX_PLAYERS_PER_GAME)
  end

  def can_complete?
    state_in_progress?
  end

  def can_cancel?
    state_created? || state_in_progress?
  end

  def self.allowed_sort_columns
    %w[created_at id state]
  end

  def self.default_sort_column
    'created_at'
  end

  def self.default_direction
    'desc'
  end

  private

  def valid_state_transition
    return if VALID_TRANSITIONS[state_was.to_sym].include?(state.to_sym)

    errors.add(:state, 'invalid state transition')
  end
end
