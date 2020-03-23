class AddColumnsToTables < ActiveRecord::Migration[5.2]
  def change
    add_column :game_users, :team,:string
  end
end
