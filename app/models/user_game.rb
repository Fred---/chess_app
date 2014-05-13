class UserGame < ActiveRecord::Base
	belongs_to :game
	belongs_to :user
	validates :game_id, presence: true
	validates :user_id, presence: true
end
