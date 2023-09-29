class CreateRound < ActiveRecord::Migration[7.0]
  def change
    create_table :rounds do |t|
      t.uuid :game, foreign_key: true
      t.uuid :player, foreign_key: true
      t.string :round_type, null: false, limit: 20
      t.integer :position
      t.jsonb :scores

      t.timestamps
    end
  end
end
