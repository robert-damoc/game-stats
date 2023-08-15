class RemoveGameIndexId < ActiveRecord::Migration[7.0]
  def change
    remove_index :games, :id
  end
end
