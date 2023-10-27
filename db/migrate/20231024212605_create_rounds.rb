class CreateRounds < ActiveRecord::Migration[7.0]
  def change
    create_table :rounds do |t|
      t.string :round_type, null: false, limit: 20
      t.integer :position
      t.jsonb :scores
      t.references :game_player, null: false, foreign_key: true

      t.timestamps
    end
  end
end
