class AddColumns2ToTables < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :status, :integer, :default => 0
    add_column :games, :score, :text
  end
end
