class GameUser < ApplicationRecord
  belongs_to :game
  belongs_to :user

  serialize :cards, Hash

end
