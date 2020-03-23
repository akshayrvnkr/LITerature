json.my_cards_html render :partial => "my_cards.html.erb"
json.players_html render :partial => "players.html.erb"
json.score_html render :partial => "score.html.erb"
json.modal_html render :partial => "modal.html.erb"
json.my_turn @game.current_player == current_user.id
json.my_cards @my_game.cards[:current]
last_movement = @game.game_user_movements.last
if last_movement
  requestee = User.find(last_movement.requestee_id).first_name
  requester = User.find(last_movement.requester_id).first_name
  card = Game.card_name(last_movement.card_no)
  json.last_move "#{requester} requested #{requestee} for #{card} #{(last_movement.fail) ? "<span style='color:red'>but failed</span>" : "<span style='color:darkgreen'>and succeeded!</span>"}"
else
  json.last_move "Last move unknown"
end