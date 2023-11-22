class Round < ApplicationRecord
  STANDARD_VALUE = 400
  QUEENS_VALUE = 100
  DIAMONDS_VALUE = 50

  ROUND_DESCRIPTION = {
    totale_minus: 'test1',
    totale_plus: 'test2',
    rentz_minus: 'test3',
    rentz_plus: 'test4',
    king: '-400 for King of Hearts',
    ten: '+400 for Ten of Clubs',
    queens: '-100 for every Queen',
    diamonds: ' -50 for every Diamond'
  }.freeze

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
    when 'ten' then validate_round_type_score(expected_value: STANDARD_VALUE, step_value: STANDARD_VALUE)
    when 'king' then validate_round_type_score(expected_value: -STANDARD_VALUE, step_value: -STANDARD_VALUE)
    when 'queens' then validate_round_type_score(expected_value: -STANDARD_VALUE, step_value: -QUEENS_VALUE)
    when 'totale_minus' then validate_totale_scores(standard_value: -STANDARD_VALUE, step_value: -DIAMONDS_VALUE)
    when 'totale_plus' then validate_totale_scores(standard_value: STANDARD_VALUE, step_value: DIAMONDS_VALUE)
    when 'rentz_minus' then validate_rentz_scores(step_value: -STANDARD_VALUE)
    when 'rentz_plus'  then validate_rentz_scores(step_value: STANDARD_VALUE)
    when 'diamonds' then validate_diamonds_scores(step_value: -DIAMONDS_VALUE)
    end
  end

  def validate_diamonds_scores(step_value:)
    expected_value = step_value * game.game_players.count * 2
    validate_round_type_score(expected_value:, step_value:)
  end

  def validate_totale_scores(standard_value:, step_value:)
    expected_value = (standard_value * 3) + (step_value * game.game_players.count * 2)
    validate_round_type_score(expected_value:, step_value:)
  end

  def validate_rentz_scores(step_value:)
    expected_value = step_value * game.game_players.count * (game.game_players.count - 1) / 2

    return errors.add(:scores, 'Each player should have a unique score.') unless
    scores.values.map(&:to_i).uniq.length == scores.values.map(&:to_i).length

    validate_round_type_score(expected_value:, step_value:)
  end

  def validate_round_type_score(expected_value:, step_value:)
    valid_total_score(expected_value:)
    valid_step_values = scores.values.all? do |score|
      (score.to_i - expected_value).modulo(step_value).zero?
    end
    valid_sign_score = scores.values.all? { |score| score.to_i.zero? || ((score.to_i <=> 0) == (step_value <=> 0)) }

    return if valid_step_values && valid_sign_score

    errors.add(:scores, "Use only scores that are multiples of #{step_value}.") unless valid_step_values
    errors.add(:scores, "Score should be 0 or have the same sign as #{step_value}.") unless valid_sign_score
  end

  def valid_total_score(expected_value:)
    return if scores.values.sum(&:to_i) == expected_value

    errors.add(:scores, "Total score should be #{expected_value}.")
  end
end
