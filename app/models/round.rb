class Round < ApplicationRecord
  acts_as_list scope: :game

  validates :round_type, presence: true

  after_validation :ensure_uniqueness

  belongs_to :game
  belongs_to :player

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

  def ensure_uniqueness
    return unless Round.where(player_id:, game_id:, round_type:).where.not(id:).any?

    errors.add(:base, 'Round with the same (player_id, game_id, round_type) already exists!')
    raise ActiveRecord::RecordInvalid, self
  end
end
