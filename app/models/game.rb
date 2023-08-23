class Game < ApplicationRecord
  include Sortable
  has_many :gameplayers
  has_many :players, through: :gameplayers

  enum state: {
    created: 'created',
    in_progress: 'in_progress',
    completed: 'completed',
    canceled: 'canceled'
  }

  def self.allowed_sort_columns
    %w[created_at id state]
  end

  def self.default_sort_column
    'created_at'
  end

  def self.default_direction
    'desc'
  end
end
