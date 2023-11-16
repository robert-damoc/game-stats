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
    when 'king'
      validate_round_type_score(-STANDARD_VALUE, -STANDARD_VALUE)
    when 'ten'
      validate_round_type_score(STANDARD_VALUE, STANDARD_VALUE)
    when 'queens'
      validate_round_type_score(-STANDARD_VALUE, QUEENS_VALUE)
    when 'diamonds'
      expected_value = -DIAMONDS_VALUE * game.game_players.count * 2
      validate_round_type_score(expected_value, -DIAMONDS_VALUE)
    when 'totale_minus', 'totale_plus'
      validate_totale_scores
    when 'rentz_minus', 'rentz_plus'
      validate_rentz_scores
    end
  end

  def validate_totale_scores
    expected_value = (STANDARD_VALUE * 3) + (DIAMONDS_VALUE * game.game_players.count * 2)
    step_value = round_type == 'totale_plus' ? DIAMONDS_VALUE : -DIAMONDS_VALUE
    validate_round_type_score(expected_value, step_value)
  end

  def validate_rentz_scores
    sign = (round_type == 'rentz_plus' ? 1 : -1)
    expected_value = sign * STANDARD_VALUE * game.game_players.count * (game.game_players.count - 1) / 2
    step_value = sign * STANDARD_VALUE

    player_scores = scores.values.map(&:to_i)

    if player_scores.uniq.length == player_scores.length
      validate_round_type_score(expected_value, step_value)
    else
      errors.add(:scores, 'Each player should have a unique score.')
    end
  end

  def validate_round_type_score(expected_value, step_value)
    total_score = scores.values.sum(&:to_i)

    return if valid_score?(total_score, expected_value, step_value)

    errors.add(:scores, "Invalid score for '#{Round.round_types[round_type]}'.")
    errors.add(:scores, "Total score should be #{expected_value}.") unless total_score == expected_value
    errors.add(:scores, "Use only multiples of #{step_value}.") unless scores.values.all? do |score|
      (score.to_i - expected_value).modulo(step_value).zero?
    end
  end

  def valid_score?(total_score, expected_value, step_value)
    total_score == expected_value && scores.values.all? do |score|
      (score.to_i - expected_value).modulo(step_value).zero?
    end
  end
end
