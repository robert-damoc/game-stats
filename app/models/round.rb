class Round < ApplicationRecord
  belongs_to :game
  belongs_to :player

  enum round: {
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
end
