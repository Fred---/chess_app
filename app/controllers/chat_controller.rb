class ChatController < WebsocketRails::BaseController
  include ActionView::Helpers::SanitizeHelper

  def initialize_session
    puts "Session Initialized\n"
  end
  
  def system_msg(ev, msg)
    broadcast_message ev, {
      user_name: 'system',
      received: Time.now.strftime('%H:%M'),
      msg_body: msg
    }
  end
  
  def user_msg(ev, msg)
    broadcast_message ev, {
      user_name: connection_store[:user][:user_name],
      received: Time.now.strftime('%H:%M'),
      msg_body: ERB::Util.html_escape(msg)
      }
  end

  def client_connected
    @user = current_user
    system_msg :new_message, @user.name + " connected"
    connection_store[:user] = { user_name: @user.name, id: @user.id }
    broadcast_user_list
  end
  
  def new_message
    user_msg :new_message, message[:msg_body].dup
  end
  
  def delete_user
    @user = current_user
    connection_store[:user] = nil
    system_msg "client disconnected"
    broadcast_user_list
  end
  
  def broadcast_user_list
    users_temp = connection_store.collect_all(:user)
    users = []
    users_temp.each do |i|
      if !users.include?(i)
        users.push(i)
      end
    end
    broadcast_message :user_list, users
  end
end