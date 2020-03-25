game_user_movements = @game.game_user_movements.count
json.move game_user_movements

json.online_status @online_status do |k,v|
  json.user_id k
  json.online v
end

json.status @game.status