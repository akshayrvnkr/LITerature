class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.string :name
      t.references :group, foreign_key: true
      t.integer :current_player

      t.timestamps
    end
  end
end
