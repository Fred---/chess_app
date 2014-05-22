class ChessController < WebsocketRails::BaseController
  include ActionView::Helpers::SanitizeHelper

  def system_msg(ev, msg)
    broadcast_message ev, {
      user_name: 'system',
      received: Time.now.to_s(:short),
      msg_body: msg
    }
  end

  def challenge
    @user = current_user
    broadcast_message :challenge, { 
      user_name: @user.name,
      user_id: @user.id,
    }
  end

  def challenge_accepted
    user1 = current_user
    channel1 = user1.name.to_s + user1.id.to_s
    user2 = User.find(message[:challenger_id])
    channel2 = user2.name.to_s + user2.id.to_s

    g = Game.create(pgn: "", status: "on going")
    system_msg :new_message, g.id

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
    user1_game = UserGame.create(user_id: user1.id, game_id: g.id, colour: user1_colour, result: "")
    user2_game = UserGame.create(user_id: user2.id, game_id: g.id, colour: user2_colour, result: "")

    #envoie de Game_id et de la couleur à chaque joueur
    WebsocketRails[channel1].trigger(:game_start, {
      game_id: g.id.to_s,
      colour: user1_colour,
      opponent_id: user2.id,
      opponent_name: user2.name
    })
    WebsocketRails[channel2].trigger(:game_start, {
      game_id: g.id.to_s,
      colour: user2_colour,
      opponent_id: user1.id,
      opponent_name: user1.name
    })
  end

  def game_move
    game = Game.find(message[:game_id])
    game.pgn = message[:pgn]
    game.save
    user_games = UserGame.where("game_id = :game_id", {game_id: message[:game_id]})

    if current_user.id == user_games.first.user_id
      user2 = User.find(user_games.second.user_id)
    else
      user2 = User.find(user_games.first.user_id)
    end

    channel2 = user2.name.to_s + user2.id.to_s

    WebsocketRails[channel2].trigger(:game_move, {
      game_id: message[:game_id],
      move: message[:move]
    })

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
  end
end