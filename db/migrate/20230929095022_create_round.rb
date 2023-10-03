class CreateRound < ActiveRecord::Migration[7.0]
  def change
    create_table :rounds do |t|
      t.references :game, foreign_key: true, type: :uuid
      t.references :player, foreign_key: true, type: :uuid
      t.string :round_type, null: false, limit: 20
      t.integer :position
      t.jsonb :scores

      t.timestamps
    end
  end
end
