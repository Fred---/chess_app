class ChessController < WebsocketRails::BaseController
  include ActionView::Helpers::SanitizeHelper

  def initialize_session
     controller_store[:message_count] = 0
  end
  
  def system_msg(ev, msg)
    broadcast_message ev, {
      user_name: 'system',
      received: Time.now.to_s(:short),
      msg_body: msg
    }
  end
  
  def user_msg(ev, msg)
    broadcast_message ev, {
      user_name: connection_store[:user][:user_name],
      received: Time.now.to_s(:short),
      msg_body: ERB::Util.html_escape(msg)
      }
  end

  def challenge
    @user = current_user
    channel = @user.name.to_s + @user.id.to_s
    system_msg :challenge, @user.name + " " + message[:msg_body]
    WebsocketRails[channel].trigger(:info, @user.id)
  end



end