json.extract! game, :id, :created_at, :updated_at, :state
json.url game_url(game, format: :json)
