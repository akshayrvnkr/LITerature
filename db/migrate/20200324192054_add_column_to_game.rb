class AddColumnToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :next_team, :string
    add_column :games, :votes, :text
  end
end
