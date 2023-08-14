class AddIndexToUuidState < ActiveRecord::Migration[7.0]
  def change
    add_index :games, :state
    add_index :games, :id, unique: true
  end
end
