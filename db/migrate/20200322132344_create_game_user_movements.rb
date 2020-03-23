class CreateGameUserMovements < ActiveRecord::Migration[5.2]
  def change
    create_table :game_user_movements do |t|
      t.references :game, foreign_key: true
      t.integer :requester_id
      t.integer :requestee_id
      t.string :card_no
      t.boolean :fail

      t.timestamps
    end
  end
end
