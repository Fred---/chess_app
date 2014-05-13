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
      msg_body: 'hello'
    }
  end

  def challenge_accepted
    user1 = current_user
    channel1 = user1.name.to_s + user1.id.to_s
    user2 = User.find(message[:challenger_id])
    channel2 = user2.name.to_s + user2.id.to_s

    g = Game.create(pgn: "")

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
    user1_game = UserGame.create(user_id: user1.id, game_id: g.id, colour: user1_colour)
    user2_game = UserGame.create(user_id: user2.id, game_id: g.id, colour: user2_colour)

    #envoie de Game_id et de la couleur à chaque joueur
    WebsocketRails[channel1].trigger(:game_start, {
      game_id: g.id.to_s,
      colour: user1_colour
    })
    WebsocketRails[channel2].trigger(:game_start, {
      game_id: g.id.to_s,
      colour: user2_colour
    })
  end

  def game_move
    user1 = current_user
    system_msg :new_message, user1.name
    
  end

end