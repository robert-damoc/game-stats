class AddIndexToRoundsOnGamePlayerIdAndRoundType < ActiveRecord::Migration[7.0]
  def change
    add_index :rounds, %i[game_player_id round_type], unique: true
  end
end
