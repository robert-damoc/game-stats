class AddUniqueIndexForRounds < ActiveRecord::Migration[7.0]
  def change
    add_index :rounds, %i[player_id game_id round_type], unique: true
  end
end
