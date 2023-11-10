class Round < ApplicationRecord
  after_initialize :set_default_scores
  before_create :set_position
  before_destroy :update_positions

  validates :round_type, presence: true
  validates :round_type, uniqueness: { scope: :game_player_id,
                                       message: 'Round already played!' }
    validate :scores_sum_validation

  belongs_to :game_player
  has_one :game, through: :game_player

  store_accessor :scores

  enum round_type: {
    totale_minus: 'Totale -',
    totale_plus: 'Totale +',
    rentz_minus: 'Rentz -',
    rentz_plus: 'Rentz +',
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
    last_position = game.rounds.where.not(id: nil).maximum(:position) || 0
    self.position = last_position + 1
  end

  def update_positions
    game.rounds.where('rounds.position > ?', position).map(&:decrement_position)
  end

  def set_default_scores
    self.scores ||= {}
  end

  def scores_sum_validation
    return if scores.blank?

    expected_score = case round_type
                     when 'totale_minus'
                       expected_score_for_totale_minus
                     when 'totale_plus'
                       expected_score_for_totale_plus
                     when 'rentz_minus'
                       expected_score_for_rentz_minus
                     when 'rentz_plus'
                       expected_score_for_rentz_plus
                     when 'king'
                       -400
                     when 'ten', 'queens'
                       400
                     when 'diamonds'
                       expected_score_for_diamonds
                     end

    actual_score = scores.values.sum(&:to_i)

    return if actual_score == expected_score

    errors.add(
      :scores,
      "Total score should be #{expected_score} for round type '#{Round.round_types[round_type]}'. Current score is #{actual_score}."
    )
  end

  def expected_score_for_totale_minus
    case game.game_players.count
    when 3
      -1500
    when 4
      -1600
    when 5
      -1700
    when 6
      -1800
    end
  end

  def expected_score_for_totale_plus
    case game.game_players.count
    when 3
      1500
    when 4
      1600
    when 5
      1700
    when 6
      1800
    end
  end

  def expected_score_for_rentz_minus
    case game.game_players.count
    when 3
      -1200
    when 4
      -2400
    when 5
      -4000
    when 6
      -6000
    end
  end

  def expected_score_for_rentz_plus
    case game.game_players.count
    when 3
      1200
    when 4
      2400
    when 5
      4000
    when 6
      6000
    end
  end

  def expected_score_for_diamonds
    case game.game_players.count
    when 3
      -300
    when 4
      -400
    when 5
      -500
    when 6
      -600
    end
  end
end
