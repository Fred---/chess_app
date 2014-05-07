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
    channel = @user.name.to_s + @user.id.to_s
    broadcast_message :challenge, { 
      user_name: @user.name,
      user_id: @user.id,
      msg_body: 'hello'
    }
    WebsocketRails[channel].trigger(:info, @user.id)
    flash[:success] = "Challenge broadcasted!"
  end

  def challenge_accepted
    
    g = Game.create(pgn: "fdfrrrd")
    system_msg :new_message, g.id.to_s + " challenged"
  end


end