jQuery ->
    window.chatController = new Chat.Controller($('#chat').data('uri'), true);

window.Chat = {}

$(document).on "click", ".user_item", ->
  chatController.dispatcher.trigger 'challenge_user', {msg_body: $(this).attr('data-user_id')}
  return
class Chat.Controller
  template: (message) ->
    html =
      """
      <div class="message" >
      <label class="label label-info">
      [#{message.received}] #{message.user_name}
      </label>&nbsp;
      #{message.msg_body}
      </div>
      """
    $(html)

  userListTemplate: (userList) ->
    userHtml = ""
    for user in userList
      userHtml = userHtml + 
      """
      <div>
        <a class="user_item" data-user_id= #{user.id}>
        #{user.user_name}
        </a>
      </div>
        """
    $(userHtml)

  constructor: (url,useWebSockets) ->
    @messageQueue = []
    @dispatcher = new WebSocketRails(url,useWebSockets)
    @channel = @dispatcher.subscribe("#{user_name}" + "#{user_id}")
    @bindEvents()

  bindEvents: =>
    @dispatcher.bind 'new_message', @newMessage
    @dispatcher.bind 'user_list', @updateUserList
    @dispatcher.bind 'challenge', @updateChallengeList
    @channel.bind 'info', @chessPlay
    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13

  newMessage: (message) =>
    @messageQueue.push message
    @shiftMessageQueue() if @messageQueue.length > 15
    @appendMessage message

  sendMessage: (event) =>
    event.preventDefault()
    message = $('#message').val()
    @dispatcher.trigger 'new_message', {user_name: user_name, msg_body: message}
    $('#message').val('')

  updateUserList: (userList) =>
    $('#user-list').html @userListTemplate(userList)

  appendMessage: (message) ->
    messageTemplate = @template(message)
    $('#chat').append messageTemplate
    messageTemplate.slideDown 140

  shiftMessageQueue: =>
    @messageQueue.shift()
    $('#chat div.messages:first').slideDown 100, ->
      $(this).remove()

  updateChallengeList: (message) =>
    messageTemplate = @template(message)
    $('#challenge-list').append messageTemplate

  chessPlay: (message) =>
    alert message

