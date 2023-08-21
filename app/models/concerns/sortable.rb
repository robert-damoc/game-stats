module Sortable
  extend ActiveSupport::Concern

  class ColumnNotSortableBy < StandardError; end
  class UndefinedDirection < StandardError; end

  class_methods do
    ALLOWED_DIRECTIONS = %w[asc desc]

    def sort_table(column_name = nil, direction = nil)
      column_name ||= default_sort_column
      direction ||= default_direction

      raise ColumnNotSortableBy, "Can't sort by #{column_name}" unless allowed_sort_columns.include?(column_name)
      raise UndefinedDirection, "Undefined direction: #{direction}" unless ALLOWED_DIRECTIONS.include?(direction)

      order(column_name => direction)
    end

    def default_sort_column
      'id'
    end

    def default_direction
      'asc'
    end
  end
end
