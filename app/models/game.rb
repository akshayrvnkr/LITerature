class Game < ApplicationRecord
  belongs_to :group

  has_many :game_users, :dependent => :destroy
  has_many :users, :through => :game_users

  has_many :game_user_movements, :dependent => :destroy

  def self.cards
    __cards = []
    ((2..7).to_a + (9..14).to_a).each do |card|
      ["D", "H", "S", "C"].each do |set|
        __cards += ["#{set}#{card}"]
      end
    end
    __cards
  end

  def self.card_name(card)
    set_map = {"D" => "Diamond",
               "H" => "Heart",
               "S" => "Spade",
               "C" => "Club"
    }
    card_map = {
        2 => "Two",
        3 => "Three",
        4 => "Four",
        5 => "Five",
        6 => "Six",
        7 => "Seven",
        9 => "Nine",
        10 => "Ten",
        11 => "Jack",
        12 => "Queen",
        13 => "King",
        14 => "Ace"
    }
    "#{card_map[card[1..-1].to_i]} of #{set_map[card[0]]}"
  end

  def self.svg_shiftx
    {
        2 => 1,
        3 => 2,
        4 => 3,
        5 => 4,
        6 => 5,
        7 => 6,
        9 => 8,
        10 => 9,
        11 => 10,
        12 => 11,
        13 => 12,
        14 => 0,
    }
  end

  def self.svg_shifty
    {
        "D" => 0,
        "H" => 1,
        "S" => 2,
        "C" => 3
    }
  end

  def user_cards(user_id)
    self.game_users.where(:user_id => user_id).first.cards[:current].sort_by { |x| "#{x[0]}#{x[1..-1].rjust(2)}" }
  end

end
