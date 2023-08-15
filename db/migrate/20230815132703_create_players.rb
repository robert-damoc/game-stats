class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players, id: :uuid do |t|
      t.string :name, limit: 30, null: false, unique: true

      t.timestamps
    end
  end
end
