class ChessController < WebsocketRails::BaseController
  include ActionView::Helpers::SanitizeHelper

  def system_msg(ev, msg)
    broadcast_message ev, {
      user_name: 'system',
      received: Time.now.strftime('%H:%M'),
      msg_body: msg
    }
  end

  def challenge
    connection_store[:user][:status] = "challenger"
    broadcast_challenge_list
  end

  def broadcast_challenge_list
    challenges_temp = connection_store.collect_all(:user)
      challenges = []
      challenges_temp.each do |i|
        if i[:status] == "challenger"
          challenges.push(i)
        end
      end
      broadcast_message :challenge_list, challenges
  end

  def challenge_accepted
    connection_store[:user][:status] = "busy"
    user1 = current_user
    user2 = User.find(message[:challenger_id])
    g = Game.create(pgn: "", status: "on going")

    # affectation au hasard de la couleur
    r=rand(2)
    if r == 1
      user1_colour="white"
      user2_colour="black"
     else
      user1_colour="black"
      user2_colour="white"
    end 
    # Maj Join Table


    #envoie de Game_id et de la couleur à chaque joueur
    broadcast_message :game_start, {
      game_id: g.id.to_s,
      colour: user1_colour,
      user_id: user1.id,
      opponent_id: user2.id,
      opponent_name: user2.name
    }
    broadcast_message :game_start, {
      game_id: g.id.to_s,
      colour: user2_colour,
      user_id: user2.id,
      opponent_id: user1.id,
      opponent_name: user1.name
    }
  end

  def game_started
    connection_store[:user][:status] = "busy"
    broadcast_challenge_list
  end

  def game_move
    game = Game.find(message[:game_id])
    game.pgn = message[:pgn]
    game.save
    user_games = UserGame.where("game_id = :game_id", {game_id: message[:game_id]})

    if current_user.id == user_games.first.user_id
      opponent = User.find(user_games.second.user_id)
    else
      opponent = User.find(user_games.first.user_id)
    end

    broadcast_message :game_move, {
      game_id: message[:game_id],
      user_id: opponent.id,
      move: message[:move]
    }

  end

  def game_over
    game = Game.find(message[:game_id])
    game.status = message[:status]
    game.save
    user_games = UserGame.where("game_id = :game_id", {game_id: message[:game_id]})

    if current_user.id == user_games.first.user_id
      user_games.first.result = "Lost"
      user_games.first.save
      user_games.second.result = "Winner"
      user_games.second.save
    else
      user_games.first.result = "Winner"
      user_games.first.save
      user_games.second.result = "Lost"
      user_games.second.save
    end
    connection_store[:user][:status] = "free"
  end
end