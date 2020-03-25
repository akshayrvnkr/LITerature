class AddCreatorIdToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :creator_id, :integer
  end
end
