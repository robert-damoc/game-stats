class CreateGame < ActiveRecord::Migration[7.0]
  def change
    create_table :games, id: :uuid do |t|
      t.string :state, limit: 30, null: false, default: :created

      t.timestamps
    end
  end
end
