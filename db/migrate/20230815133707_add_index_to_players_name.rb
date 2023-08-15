class AddIndexToPlayersName < ActiveRecord::Migration[7.0]
  def change
    add_index :players, :name, unique: true
    add_index :players, :id, unique: true
  end
end
