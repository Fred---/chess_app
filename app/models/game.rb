class Game < ActiveRecord::Base
	has_many :users_games
	has_many :users, through: :users_games, source: :user
end
