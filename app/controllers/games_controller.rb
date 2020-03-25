class GamesController < ApplicationController
  before_action :disable_access, only: [:destroy, :index]
  before_action :set_game, only: [:show, :edit, :update, :destroy, :refresh, :status, :request_card, :declare, :next_player]
  before_action :set_group, only: [:declare]
  before_action :set_my_game, only: [:show, :refresh, :declare, :status]
  before_action :set_online_status, only: [:show, :refresh, :status]

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
    @my_game.update(:last_online => Time.now)
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

  def next_player
    if @game.next_team
      if @my_game.team == @game.next_team
      else
        @error = "Next player is not from your team"
      end
    else
      @error = "It's not the time to select next player"
    end
  end

  def declare
    if current_user.id != @game.current_player or @game.next_team
      @error = "You are not the current player"
    elsif @game.inactive
      @message = "The game is in an inactive state"
      @fail = true
    else
      set_claim = params[:set_claim]
      claim_map = params[:claim_map].to_unsafe_h #{"C2"=>2, "C3"=>2, "C4"=>5, "C5"=>5, "C6"=>6, "C7"=>6}
      claim_map = claim_map.map { |k, v| [k, v.to_i] }.to_h

      if claim_map.size == 6
        all_in_same_deck = true
        claim_map.each do |card_no, user_id|
          all_in_same_deck &= (get_base(card_no) == set_claim)
        end
        if all_in_same_deck
          game_all_users = GameUser.where(:game_id => @game.id)
          requester_cards = @my_game.cards[:current]
          # Fetch user IDs of my team members, claim request shouldn't have users outside it
          my_team_ids = game_all_users.select { |x| x.team == @my_game.team }.map { |x| x.user_id }
          request_team_ids = claim_map.values.uniq
          if (request_team_ids & my_team_ids) == request_team_ids
            # The declarer has atleast one card in the declaration set
            in_deck = (requester_cards & claim_map.keys).present?
            if in_deck
              # Create a dictionary of cards with each user_id
              all_user_cards = game_all_users.map { |x| [x.user_id, x.cards[:current]] }.to_h
              claim_correct = true
              claim_map.each do |card_no, user_id|
                user_cards = all_user_cards[user_id]
                claim_correct = false if !user_cards.include?(card_no)
              end
              all_my_team_cards = my_team_ids.map { |x| all_user_cards[x] }.flatten
              all_cards_not_in_my_team = (claim_map.keys - all_my_team_cards).present?

              GameUserMovement.create(:game_id => @game.id, :requester_id => current_user.id,
                                      :card_no => set_claim, :claim => ((claim_correct) ? 2 : 0) + ((all_cards_not_in_my_team) ? 1 : 0))
              delete_cards(set_claim)
              set_points(set_claim, claim_correct, all_cards_not_in_my_team, @my_game.team)
              next_player = nil
              if claim_correct
                if @my_game.cards[:current].size == 0
                  my_team_other_members = (my_team_ids - [current_user.id])
                  possible_team_members = []
                  my_team_other_members.each do |user_id|
                    possible_team_members += [user_id] if GameUser.where(:game_id => @game.id, :user_id => user_id).first.cards[:current].size != 0
                  end
                  next_player = possible_team_members.sample
                else
                  next_player = current_user.id
                end
                # @game.update(:next_team => @my_game.team, :votes => {}, :current_player => next_player)
                @game.update(:current_player => next_player)
                @game.update(:status => 3) if next_player.nil?
                @success = "Your claim was correct. The #{Game.deck_name(set_claim)} has been won."
              else
                other_team_ids = game_all_users.select { |x| x.team != @my_game.team }.map { |x| x.user_id }
                last_other_team = GameUserMovement.where(:game_id => @game.id, :requester_id => other_team_ids).last
                search_other_members = last_other_team.nil?
                if last_other_team
                  next_player = last_other_team.requester_id
                  search_other_members = true if GameUser.where(:game_id => @game.id, :user_id => last_other_team.requester_id).first.cards[:current].size == 0
                end
                if search_other_members
                  possible_team_members = []
                  other_team_ids.each do |user_id|
                    possible_team_members += [user_id] if GameUser.where(:game_id => @game.id, :user_id => user_id).first.cards[:current].size != 0
                  end
                  next_player = possible_team_members.sample
                end
                # @game.update(:next_team => (@my_game.team == "A") ? "B" : "A", :votes => {}, :current_player=>nil)
                @game.update(:current_player => next_player)
                @game.update(:status => 3) if next_player.nil?
                @error = "The claim was incorrect. The #{Game.deck_name(set_claim)} has been lost. All cards were#{" not" if all_cards_not_in_my_team} in your team."
              end
            else
              @error = "Declarer doesn't have even one card claimed"
            end
          else
            @error = "Claim contains members from other team"
          end
        else
          @error = "All cards are not from the same deck"
        end
      else
        @error = "No. of cards claimed is not 6"
      end
    end
  end

  def request_card
    if current_user.id != @game.current_player or @game.next_team
      @message = "You are not the current player"
      @fail = true
    elsif @game.inactive
      @message = "The game is in an inactive state"
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
    Game.get_base(card)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
  end

  def set_group
    @group = Group.find(@game.group_id)
  end

  def set_online_status
    if @my_game.last_online.nil? or (@my_game.last_online and (Time.now - @my_game.last_online) >= 56.seconds)
      @my_game.update(:last_online => Time.now)
    end
    last_movement = GameUserMovement.where(:game_id => @game.id).last
    game_users = GameUser.where(:game_id => @game.id).select(:user_id, :last_online)
    check_time = @game.created_at
    check_time = last_movement.created_at if last_movement
    @online_status = game_users.map { |x| [x.user_id, ((x.last_online and (x.last_online > check_time) and (Time.now - x.last_online) < 1.minute) or false)] }.to_h
  end

  def delete_cards(base)
    addendum = (base[1] == "L") ? 0 : 7
    cards_to_delete = ((addendum + 2)..(addendum + 7)).map { |x| "#{base[0]}#{x}" }
    GameUser.where(:game_id => @game.id).each do |game_user|
      cards = game_user.cards
      cards[:current] = cards[:current] - cards_to_delete
      game_user.update(:cards => cards)
    end
    set_my_game
  end

  def set_points(set_claim, claim_correct, all_cards_not_in_my_team, team)
    score = (@game.score or {})
    set_score = (set_claim[1] == "L") ? 1 : 2
    scoring_team = team
    final_score = set_score
    if claim_correct
    elsif all_cards_not_in_my_team
      scoring_team = (team == "A") ? "B" : "A"
    else
      final_score = 0
    end
    score[scoring_team] = (score[scoring_team] or 0) + final_score
    @game.update(:score => score)
  end

  def set_my_game
    @my_game = GameUser.where(:game_id => @game.id, :user_id => current_user.id).first
  end

  # Only allow a list of trusted parameters through.
  def game_params
    params.require(:game).permit(:name, :group_id, :current_player)
  end
end
