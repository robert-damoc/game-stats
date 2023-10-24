class CreateRound < ActiveRecord::Migration[7.0]
  def change
    create_table :rounds do |t|
      t.references :game_player
      t.string :round_type, null: false, limit: 20
      t.integer :position
      t.jsonb :scores

      t.timestamps
    end
  end
end
