json.extract! game, :id, :name, :group_id, :current_player, :created_at, :updated_at
json.url game_url(game, format: :json)
