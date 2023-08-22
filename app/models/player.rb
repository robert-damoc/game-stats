class Player < ApplicationRecord
  include Sortable
  validates :name, presence: true, length: { maximum: 30 }

  def self.allowed_sort_columns
    %w[name]
  end

  def self.default_sort_column
    'name'
  end

  def self.default_direction
    'asc'
  end
end
