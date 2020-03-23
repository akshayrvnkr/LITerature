class CreateGameUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :game_users do |t|
      t.references :game, foreign_key: true
      t.references :user, foreign_key: true
      t.text :cards
      t.datetime :last_online

      t.timestamps
    end
  end
end
