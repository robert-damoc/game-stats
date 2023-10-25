class Round < ApplicationRecord
  acts_as_list scope: :game_player

  validates :round_type, presence: true

  validate :unique_round_for_player_in_game

  belongs_to :game_player

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

  def unique_round_for_player_in_game
    if Round.where(game_player_id:, round_type:)
            .where.not(id:)
            .joins(:game_player)
            .where(game_players: { game_id: game_player.game_id })
            .any?
      errors.add(:base, 'Round with the same (player_id, game_id, round_type) already exists!')
    end
  end
end
