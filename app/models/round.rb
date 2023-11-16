class Round < ApplicationRecord
  STANDARD_VALUE = 400
  QUEENS_VALUE = 100
  DIAMONDS_VALUE = 50

  after_initialize :set_default_scores
  before_validation :validate_scores, on: :update
  before_create :set_position
  before_destroy :update_positions

  validates :round_type, presence: true
  validates :round_type, uniqueness: { scope: :game_player_id,
                                       message: 'Round already played!' }

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

  def validate_scores
    case round_type
    when 'ten' then validate_round_type_score(STANDARD_VALUE, STANDARD_VALUE)
    when 'king' then validate_round_type_score(-STANDARD_VALUE, -STANDARD_VALUE)
    when 'queens' then validate_round_type_score(-STANDARD_VALUE, -QUEENS_VALUE)
    when 'totale_minus', 'totale_plus' then validate_totale_scores
    when 'rentz_minus', 'rentz_plus' then validate_rentz_scores
    when 'diamonds'
      expected_value = -DIAMONDS_VALUE * game.game_players.count * 2
      validate_round_type_score(expected_value, -DIAMONDS_VALUE)
    end
  end

  def validate_totale_scores
    expected_value = (STANDARD_VALUE * 3) + (DIAMONDS_VALUE * game.game_players.count * 2)
    if round_type == 'totale_plus'
      validate_round_type_score(expected_value, DIAMONDS_VALUE)
    else
      validate_round_type_score(-expected_value, -DIAMONDS_VALUE)
    end
  end

  def validate_rentz_scores
    step_value = (round_type == 'rentz_plus' ? STANDARD_VALUE : -STANDARD_VALUE)
    expected_value = step_value * game.game_players.count * (game.game_players.count - 1) / 2

    validate_rentz_unique_scores(expected_value, step_value)
  end

  def validate_rentz_unique_scores(expected_value, step_value)
    return errors.add(:scores, 'Each player should have a unique score.') unless
      scores.values.map(&:to_i).uniq.length == scores.values.map(&:to_i).length

    validate_round_type_score(expected_value, step_value)
  end

  def validate_round_type_score(expected_value, step_value)
    total_score = scores.values.sum(&:to_i)

    validate_total_score?(total_score, expected_value)
    validate_individual_scores(expected_value, step_value)
  end

  def validate_total_score?(total_score, expected_value)
    return true if total_score == expected_value

    errors.add(:scores, "Total score should be #{expected_value}.")
    false
  end

  def validate_individual_scores(expected_value, step_value)
    validate_step_values = scores.values.all? { |score| (score.to_i - expected_value).modulo(step_value).zero? }
    validate_individual_values = scores.values.all? { |score| score.to_i <= expected_value }

    return true if validate_step_values && validate_individual_values

    errors.add(:scores, "Use only multiples of #{step_value}.") unless validate_step_values
    errors.add(:scores, "Each score should be at most #{expected_value}.") unless validate_individual_values

    false
  end
end
