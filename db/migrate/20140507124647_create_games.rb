class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :pgn
      t.timestamp :start_time
      t.timestamp :end_time
      t.string :status

      t.timestamps
    end
  end
end
