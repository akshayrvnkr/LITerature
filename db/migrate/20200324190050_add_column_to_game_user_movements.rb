class AddColumnToGameUserMovements < ActiveRecord::Migration[5.2]
  def change
    add_column :game_user_movements, :claim, :integer
  end
end
