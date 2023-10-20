class Round < ApplicationRecord
  validates :round_type, presence: true
  validates :player_id,
            uniqueness: true,
            scope: %i[game_id round_type],
            message: 'A player can only have one round of a given type per game.'

  belongs_to :game
  belongs_to :player

  enum round_type: {
    rentz_minus: 'Rentz-',
    rentz_plus: 'Rentz+',
    totale_minus: 'Totale-',
    totale_plus: 'Totale+',
    king: 'King of hearts',
    ten: 'Ten of clubs',
    queens: 'Queens',
    diamonds: 'Diamonds'
  }
end
