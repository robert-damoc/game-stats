class Game < ApplicationRecord
  include Sortable

  before_update :valid_state_transition

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
    message: 'There can be a maximum of 8 players in a game.'
  }, on: %i[create update]

  has_many :game_players, -> { order(position: :asc) }, dependent: :destroy, inverse_of: :game
  has_many :players, through: :game_players

  enum state: {
    created: 'created',
    in_progress: 'in_progress',
    completed: 'completed',
    canceled: 'canceled'
  }, _prefix: true

  def valid_state_transition
    return if VALID_TRANSITIONS[state_was.to_sym].include?(state.to_sym)

    if state == 'in_progress'
      unless player_ids.count.between?(Game::MIN_PLAYERS_PER_GAME, Game::MAX_PLAYERS_PER_GAME)
        errors.add(:state, 'Invalid state transition. The game must have between 2 and 8 players to start.')
      end
    else
      errors.add(:state, 'Invalid state transition')
    end
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
end
