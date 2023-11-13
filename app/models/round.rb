class Round < ApplicationRecord
  POSITIVE_VALUE = 400
  NEGATIVE_VALUE = -400
  POSITIVE_DIAMONDS = 50
  NEGATIVE_DIAMONDS = -50

  after_initialize :set_default_scores
  before_create :set_position
  before_destroy :update_positions

  validates :round_type, presence: true
  validates :round_type, uniqueness: { scope: :game_player_id,
                                       message: 'Round already played!' }
  validate :validate_scores

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
      validate_round_type_score(NEGATIVE_VALUE, (0..NEGATIVE_VALUE).step(-400).to_a, -400)
    when 'ten'
      validate_round_type_score(POSITIVE_VALUE, (0..POSITIVE_VALUE).step(400).to_a, 400)
    when 'queens'
      validate_round_type_score(NEGATIVE_VALUE, (0..NEGATIVE_VALUE).step(-100).to_a, 100)
    when 'diamonds'
      expected_value = NEGATIVE_DIAMONDS * game.game_players.count * 2
      validate_round_type_score(expected_value, (0..NEGATIVE_VALUE).step(-50).to_a, -50)
    when 'totale_minus', 'totale_plus'
      validate_totale_scores(round_type)
    when 'rentz_minus', 'rentz_plus'
      validate_rentz_scores(round_type)
    end
  end

  def validate_totale_scores(round_type)
    if round_type == 'totale_plus'
      expected_value = (POSITIVE_VALUE * 3) + (POSITIVE_DIAMONDS * game.game_players.count * 2)
      allowed_values = (0..expected_value).step(50).to_a
      validate_round_type_score(expected_value, allowed_values, 50)
    else
      expected_value = (NEGATIVE_VALUE * 3) + (NEGATIVE_DIAMONDS * game.game_players.count * 2)
      allowed_values = (0..expected_value).step(-50).to_a
      validate_round_type_score(expected_value, allowed_values, -50)
    end
  end

  def validate_rentz_scores(round_type)
    expected_value = case game.game_players.count
                     when 3
                       (round_type == 'rentz_plus' ? POSITIVE_VALUE : NEGATIVE_VALUE) * 3
                     when 4
                       (round_type == 'rentz_plus' ? POSITIVE_VALUE : NEGATIVE_VALUE) * 6
                     when 5
                       (round_type == 'rentz_plus' ? POSITIVE_VALUE : NEGATIVE_VALUE) * 10
                     when 6
                       (round_type == 'rentz_plus' ? POSITIVE_VALUE : NEGATIVE_VALUE) * 15
                     end
    allowed_values = (0..expected_value).step(round_type == 'rentz_plus' ? 400 : -400).to_a
    validate_round_type_score(expected_value, allowed_values, round_type == 'rentz_plus' ? 400 : -400)
  end

  def validate_round_type_score(expected_value, allowed_values, step)
    total_score = scores.values.sum(&:to_i)

    return if total_score == expected_value && scores.values.all? { |score| allowed_values.include?(score.to_i) }

    errors.add(:scores, "Invalid score for '#{Round.round_types[round_type]}'.\n" \
                        "Total score should be #{expected_value}.\n" \
                        "Use only multiples of #{step} from 0 to #{expected_value}.")
  end
end
