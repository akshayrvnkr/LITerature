json.extract! game_user, :id, :game_id, :user_id, :cards, :last_online, :created_at, :updated_at
json.url game_user_url(game_user, format: :json)
