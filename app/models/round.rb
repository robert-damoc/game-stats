class Round < ApplicationRecord

  validates :round_type, presence: true
  validates :game_id, uniqueness: true, message: 'This game already started or has been played.'
  validates :player_id,
            uniqueness: true,
            scope: %i[game_id round_type],
            message: 'A player can only have one round of a given type per game.'
  validate :unique_round_type_per_game

  belongs_to :game
  belongs_to :player

  enum round_type: {
    king: 'king',
    queens: 'queens',
    diamonds: 'diamonds',
    levate: 'levate',
    rentz_minus: 'rentz_minus',
    rentz_plus: 'rentz_plus',
    whist: 'whist',
    ten: 'ten',
    totale_minus: 'totale_minus',
    totale_plus: 'totale_plus'
  }

  private

  def unique_round_type_per_game
    if game_id && player_id
      if Round.where(game_id: game_id, round_type: round_type).where.not(player_id: player_id).exists?
        errors.add(:round_type, "has already been chosen by another player for this game")
      end
    end
  end

end
