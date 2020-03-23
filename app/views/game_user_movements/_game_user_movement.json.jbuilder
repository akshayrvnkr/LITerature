json.extract! game_user_movement, :id, :game_id, :requester_id, :requestee_id, :card_no, :fail, :created_at, :updated_at
json.url game_user_movement_url(game_user_movement, format: :json)
