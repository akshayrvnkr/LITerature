module GamesHelper

  def generate_card(card_no)
    shift_x = Game.svg_shiftx
    shift_y = Game.svg_shifty
    card_sx = -shift_x[card_no[1..-1].to_i] * 50 - 5
    card_sy = -shift_y[card_no[0]] * 70 - 5
    "<img src=\"/small_playing_cards.svg\" style=\"width:50px;height:70px;object-fit: none;
      object-position: #{card_sx}px #{card_sy}px; \"alt=\"#{card_no}\"/>".html_safe
  end
end
