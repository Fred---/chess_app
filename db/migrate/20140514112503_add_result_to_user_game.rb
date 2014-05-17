class AddResultToUserGame < ActiveRecord::Migration
  def change
    add_column :user_games, :result, :string
  end
end
