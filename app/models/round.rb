class Round < ApplicationRecord
  STANDARD_VALUE = 400
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
    when 'king' then validate_king_scores
    when 'ten' then validate_ten_scores
    when 'queens' then alidate_queens_scores
    when 'diamonds' then validate_diamonds_scores
    when 'totale_minus', 'totale_plus' then validate_totale_scores
    when 'rentz_minus', 'rentz_plus' then validate_rentz_scores
    end
  end

  def validate_king_scores
    validate_round_type_score(-STANDARD_VALUE, (0..-STANDARD_VALUE).step(-STANDARD_VALUE).to_a, -STANDARD_VALUE)
  end

  def validate_ten_scores
    validate_round_type_score(STANDARD_VALUE, (0..STANDARD_VALUE).step(STANDARD_VALUE).to_a, STANDARD_VALUE)
  end

  def validate_queens_scores
    validate_round_type_score(-STANDARD_VALUE, (0..-STANDARD_VALUE).step(-100).to_a, -100)
  end

  def validate_diamonds_scores
    expected_value = -DIAMONDS_VALUE * game.game_players.count * 2
    validate_round_type_score(expected_value, (0..-STANDARD_VALUE).step(-DIAMONDS_VALUE).to_a, -DIAMONDS_VALUE)
  end

  def validate_totale_scores
    if round_type == 'totale_plus'
      expected_value = (STANDARD_VALUE * 3) + (DIAMONDS_VALUE * game.game_players.count * 2)
      validate_round_type_score(expected_value, (0..expected_value).step(50).to_a, 50)
    else
      expected_value = -(STANDARD_VALUE * 3) - (DIAMONDS_VALUE * game.game_players.count * 2)
      validate_round_type_score(expected_value, (0..expected_value).step(-50).to_a, -50)
    end
  end

  def validate_rentz_scores
    step_value = round_type == 'rentz_plus' ? 400 : -400
    player_scores = scores.values.map(&:to_i)

    if player_scores.uniq.length == player_scores.length
      validate_round_type_score(rentz_expected_value, (0..expected_value).step(step_value).to_a, step_value)
    else
      errors.add(:scores, 'Each player should have a unique score.')
    end
  end

  def rentz_expected_value
    case game.game_players.count
    when 3
      (round_type == 'rentz_plus' ? STANDARD_VALUE : -STANDARD_VALUE) * 3
    when 4
      (round_type == 'rentz_plus' ? STANDARD_VALUE : -STANDARD_VALUE) * 6
    when 5
      (round_type == 'rentz_plus' ? STANDARD_VALUE : -STANDARD_VALUE) * 10
    when 6
      (round_type == 'rentz_plus' ? STANDARD_VALUE : -STANDARD_VALUE) * 15
    end
  end

  def validate_round_type_score(expected_value, allowed_values, step_value)
    total_score = scores.values.sum(&:to_i)

    return if total_score == expected_value && scores.values.all? { |score| allowed_values.include?(score.to_i) }

    errors.add(:scores, "Invalid score for '#{Round.round_types[round_type]}'. " \
                        "Total score should be #{expected_value}. " \
                        "Use only multiples of #{step_value} from 0 to #{expected_value}.")
  end
end
