json.array!(@games) do |game|
  json.extract! game, :id, :pgn, :start_time, :end_time, :status
  json.url game_url(game, format: :json)
end
