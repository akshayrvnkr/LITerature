class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy, :refresh, :status, :request_card]
  before_action :set_my_game, only: [:show, :refresh]

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show

  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  def refresh
    respond_to do |format|
      format.json
      format.js
    end
  end

  def status
    respond_to do |format|
      format.json
      format.js
    end
  end

  def request_card
    if current_user.id != @game.current_player
      @message = "You are not the current player"
      @fail = true
    else
      requester_id = current_user.id
      requestee_id = params[:requestee_id]
      card_no = params[:card_no]

      requestee_game = GameUser.where(:user_id => requestee_id, :game_id => @game.id).first
      requester_game = GameUser.where(:user_id => requester_id, :game_id => @game.id).first
      if requestee_game and requester_game
        requestee_cards = requestee_game.cards
        requester_cards = requester_game.cards

        check_own = !requester_cards[:current].include?(card_no)
        in_deck = false

        requester_cards[:current].each do |card|
          in_deck = true if get_base(card) == get_base(card_no)
        end

        if check_own and in_deck and requestee_cards[:current].include?(card_no)
          @fail = false
          requestee_cards[:current].delete(card_no)
          requester_cards[:current] = requester_cards[:current] + [card_no]
          requestee_game.update(:cards => requestee_cards)
          requester_game.update(:cards => requester_cards)
        else
          @fail = true
        end
        GameUserMovement.create(:requestee_id => requestee_id,
                                :requester_id => requester_id,
                                :card_no => card_no,
                                :fail => @fail,
                                :game_id => @game.id
        )
        if @fail
          @game.update(:current_player => requestee_id)
        end
      end
      @message = false
    end

    respond_to do |format|
      format.json
      format.html
      format.js
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def get_base(card)
    "#{card[0]}#{(card[1..-1].to_i > 7)?"L":"H"}"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
  end

  def set_my_game
    @my_game = GameUser.where(:game_id => @game.id, :user_id => current_user.id).first
  end

  # Only allow a list of trusted parameters through.
  def game_params
    params.require(:game).permit(:name, :group_id, :current_player)
  end
end
