class Round < ApplicationRecord
  before_create :set_position
  before_destroy :update_positions

  validates :round_type, presence: true
  validates :round_type, uniqueness: { scope: :game_player_id,
                                       message: 'Round already played!' }

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

  def set_position
    last_position = game_player.game.rounds.where.not(id: nil).maximum(:position) || 0
    self.position = last_position + 1
  end

  def update_positions
    game.rounds.where('rounds.position > ?', position).map(&:decrement_position)
  end
end
