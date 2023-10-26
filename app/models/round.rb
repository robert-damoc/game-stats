class Round < ApplicationRecord
  before_create :set_position
  before_destroy :update_positions

  validates :round_type, presence: true
  validate :unique_round_for_player_in_game

  belongs_to :game_player
  has_one :game, through: :game_player

  enum round_type: {
    rentz_minus: 'Rentz -',
    rentz_plus: 'Rentz +',
    totale_minus: 'Totale -',
    totale_plus: 'Totale +',
    king: 'King of hearts',
    ten: 'Ten of clubs',
    queens: 'Queens',
    diamonds: 'Diamonds'
  }

  def decrement_position
    self.position -= 1
    save!
  end

  private

  def unique_round_for_player_in_game
    if Round.where(game_player_id:, round_type:)
            .where.not(id:)
            .joins(:game_player)
            .where(game_players: { game_id: game_player.game_id })
            .any?
      errors.add(:base, 'Round with the same (player_id, game_id, round_type) already exists!')
    end
  end

  def set_position
    last_position = game.rounds.where.not(id: nil).maximum(:position) || 0
    self.position = last_position + 1
  end

  def update_positions
    if last_in_game_player_list?
      next_round = game.rounds.order(:created_at).last
      next_round&.update(position:)
    else
      game.rounds.where('rounds.position > ?', position).map(&:decrement_position)
    end
  end

  def last_in_game_player_list?
    game.rounds.order(:position).last == self
  end
end
