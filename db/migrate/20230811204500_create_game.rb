class CreateGame < ActiveRecord::Migration[7.0]
  def change
    create_table :games, id: :uuid do |t|

      t.timestamps
    end
  end
end
