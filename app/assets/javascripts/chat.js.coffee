jQuery ->
    window.chatController = new Chat.Controller($('#chat').data('uri'), true);

window.Chat = {}

$(document).on "click", "#send_challenge", ->
  chatController.dispatcher.trigger 'challenge_user', {msg_body: "hello"}
  return

$(document).on "click", ".challenge_button", (e) ->
  e.preventDefault()
  chatController.dispatcher.trigger 'challenge_accepted', {
    user_id: user_id, 
    challenger_id: 42
  }
  return


class Chat.Controller
  challengeListTemplate: (challengeList) ->
    html = ""
    for challenge in challengeList
      if challenge.user_id != user_id
        html = html + 
        """
        <li class="list-group-item challenge_item" >
          #{challenge.user_name}
        <button type="button" class="btn btn-sm btn-primary challenge_button" data-user_id= #{challenge.user_id}>
         accept
        </button>
        </li>
        """
    $(html)

  template: (message) ->
    html =
      """
      <div class="message" >
      <label class="label label-info">
      #{message.received} #{message.user_name}
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
        <a class="user_item" data-user_id= #{user.user_id}>
        #{user.user_name}
        </a>
      </div>
        """
    $(userHtml)

  pgnTemplate: (pgn) ->
    html = ""
    for move in pgn
      line = move.split(" ")
      if typeof line[1] != 'undefined'
        line[2] = "--" unless typeof line[2] != 'undefined'
        html = html + 
        """
        <tr>
          <td>#{line[0]}</td>
          <td>#{line[1]}</td>
          <td>#{line[2]}</td>
        </tr>
        """
    $(html)

  constructor: (url,useWebSockets) ->
    @messageQueue = []
    @dispatcher = new WebSocketRails(url,useWebSockets)
    @bindEvents()

  bindEvents: =>
    @dispatcher.bind 'new_message', @newMessage
    @dispatcher.bind 'user_list', @updateUserList
    @dispatcher.bind 'challenge_list', @updateChallengeList
    @dispatcher.bind 'game_start', @gameStart
    @dispatcher.bind 'game_move', @gameMove
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
    $('#chat').scrollTop = $('#chat').scrollHeight

  shiftMessageQueue: =>
    @messageQueue.shift()
    $('#chat div.messages:first').slideDown 100, ->
      $(this).remove()

  updateChallengeList: (challengeList) =>
    $('#challenge-list').html @challengeListTemplate(challengeList)

  gameStart: (message) =>
    if message.user_id == user_id
      window.game = new Chess()
      window.game_id = message.game_id
      # do not pick up pieces if the game is over
      # only pick up pieces for the side to move
      onDragStart = (source, piece, position, orientation) ->
        false  if game.game_over() is true or (game.turn() is "w" and piece.search(/^b/) isnt -1) or (game.turn() is "b" and piece.search(/^w/) isnt -1) or (orientation is "white" and piece.search(/^w/) is -1) or (orientation is "black" and piece.search(/^b/) is -1)

      onDrop = (source, target) ->
        # see if the move is legal
        move = game.move(
          from: source
          to: target
          promotion: "q" # NOTE: always promote to a queen for example simplicity
        )
        # illegal move
        return "snapback"  if move is null
        chatController.dispatcher.trigger 'game_move', {game_id: game_id, pgn: game.pgn(), turn: game.turn(), move: move}
        chatController.updateStatus()
        return
      # update the board position after the piece snap 
      # for castling, en passant, pawn promotion
      onSnapEnd = ->
        board.position game.fen()
        return

      cfg =
        draggable: true
        pieceTheme: "../images/chesspieces/wikipedia/{piece}.png"
        position: "start"
        onDragStart: onDragStart
        onDrop: onDrop
        onSnapEnd: onSnapEnd
        moveSpeed: 'slow'
        snapbackSpeed: 500
        snapSpeed: 100
        orientation: message.colour

      window.board = new ChessBoard("board", cfg)

      @updateStatus()
      chatController.dispatcher.trigger 'game_started', {game_id: game_id, user_id: user_id}
      $("#opponent").html message.opponent_name

  gameMove: (message) =>
    if message.user_id == user_id
      game.move message.move
      board.position game.fen()
      chatController.updateStatus()
      if game.in_checkmate() is true
        chatController.dispatcher.trigger 'game_over', {game_id: game_id, pgn: game.pgn(), status: "checkmate"}
      else if game.in_draw() is true
        chatController.dispatcher.trigger 'game_over', {game_id: game_id, pgn: game.pgn(), status: "drawn"}
      
  updateStatus: =>
    status = ""
    state = "on going"
    moveColor = "White"
    moveColor = "Black"  if game.turn() is "b"
      
    # checkmate?
    if game.in_checkmate() is true
      state = "checkmate"
      status = "Game over, " + moveColor + " is in checkmate."
    # draw?
    else if game.in_draw() is true
      state = "drawn"
      status = "Game over, drawn position"
    # game still on
    else
      status = moveColor + " to move"
      state = "on going"
        
      # check?
      status += ", " + moveColor + " is in check"  if game.in_check() is true
    #update pgn box
    pgn = game.pgn({ max_width: 5, newline_char: '$' })
    pgn = pgn.split("$")
    $("#game_pgn").html @pgnTemplate(pgn)

    $("#status").html status
    return state
