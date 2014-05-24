class Game < ActiveRecord::Base
	has_many :user_games, foreign_key: "game_id"
	has_many :users, through: :user_games
end
