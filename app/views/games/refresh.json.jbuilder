json.my_cards_html render :partial => "my_cards.html.erb"
json.players_html render :partial => "players.html.erb"
json.score_html render :partial => "score.html.erb"
json.modal_html render :partial => "modal.html.erb"
json.declare_html render :partial => "declare.html.erb"
json.my_turn @game.current_player == current_user.id
json.my_cards @my_game.cards[:current]
json.next_team @game.next_team
last_movement = @game.game_user_movements.last
if last_movement
  requester = User.find(last_movement.requester_id).first_name
  if last_movement.claim
    card = Game.deck_name(last_movement.card_no)
    if last_movement.claim >= 2
      message = "<span style='color:darkgreen'>and succeeded</span>"
    elsif last_movement.claim == 1
      message = "<span style='color:red'>but failed and all cards of the deck did not belong to their team</span>"
    else
      message = "<span style='color:red'>but failed although all cards of the deck belonged to their team</span>"
    end
    json.last_move "#{requester} declared the #{card} #{message}"
  else
    requestee = User.find(last_movement.requestee_id).first_name
    card = Game.card_name(last_movement.card_no)
    json.last_move "#{requester} requested #{requestee} for #{card} #{(last_movement.fail) ? "<span style='color:red'>but failed</span>" : "<span style='color:darkgreen'>and succeeded!</span>"}"
  end
else
  json.last_move "Last move unknown"
end