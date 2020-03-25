class GroupsController < ApplicationController
  before_action :disable_access, only: [:destroy, :index, :create]
  before_action :set_group, only: [:show, :edit, :update, :destroy, :new_game]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    @group.creator_id = current_user.id
    #can_create = [6, 8].include?(params[:group][:members]&.keys&.size)
    #flash[:alert] = "Number of members should be 6 or 8" if !can_create
    respond_to do |format|
      if @group.save and can_create
        @group.users = User.where(:id => params[:group][:members].keys)
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { redirect_to "/" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def new_game
    users = @group.users
    group_users = users.ids
    user_ids = params[:user_ids].map { |x| x.to_i }
    if (user_ids - group_users).present?
      @error = "All players are not from the same group"
      return
    end
    if user_ids.count != 6 and user_ids.count != 8
      @error = "Number of players must be 6 or 8"
      return
    end
    @game = Game.create(:name => SecureRandom.uuid,
                        :group_id => @group.id,
                        :current_player => user_ids.sample,
                        :status => 1,
                        :creator_id => current_user.id
    )
    cards = Game.cards
    no_of_cards_per_user = (cards.size / user_ids.size).to_i
    split_cards = cards.shuffle.each_slice(no_of_cards_per_user).to_a
    teams = ["A", "B"] * (user_ids.size / 2).to_i
    user_ids.shuffle.each_with_index do |uid, index|
      GameUser.find_or_create_by(:user_id => uid, :game_id => @game.id) do |game_user|
        game_user.cards = {:current => split_cards[index].dup, :original => split_cards[index].dup}
        game_user.team = teams.pop
      end
    end
    @redirect = game_path(@game)
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: 'Group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.require(:group).permit(:name)
  end
end
