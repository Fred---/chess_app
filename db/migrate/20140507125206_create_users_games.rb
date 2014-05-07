class CreateUsersGames < ActiveRecord::Migration
  def change
    create_table :users_games do |t|
      t.integer :game_id
      t.integer :user_id
      t.string :colour

      t.timestamps
    end
    add_index :users_games, :game_id
    add_index :users_games, :user_id
    add_index :users_games, [:game_id, :user_id], unique: true
  end
end
