class CreateGamePlayer < ActiveRecord::Migration[7.0]
  def change
    create_table :game_players do |t|
      t.integer :position
      t.references :game, foreign_key: true, type: :uuid
      t.references :player, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
