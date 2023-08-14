class AddIndexToUuidState < ActiveRecord::Migration[7.0]
  def change
    add_index :games, :state
  end
end
