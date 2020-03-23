class GameUserMovementsController < ApplicationController
  before_action :set_game_user_movement, only: [:show, :edit, :update, :destroy]

  # GET /game_user_movements
  # GET /game_user_movements.json
  def index
    @game_user_movements = GameUserMovement.all
  end

  # GET /game_user_movements/1
  # GET /game_user_movements/1.json
  def show
  end

  # GET /game_user_movements/new
  def new
    @game_user_movement = GameUserMovement.new
  end

  # GET /game_user_movements/1/edit
  def edit
  end

  # POST /game_user_movements
  # POST /game_user_movements.json
  def create
    @game_user_movement = GameUserMovement.new(game_user_movement_params)

    respond_to do |format|
      if @game_user_movement.save
        format.html { redirect_to @game_user_movement, notice: 'Game user movement was successfully created.' }
        format.json { render :show, status: :created, location: @game_user_movement }
      else
        format.html { render :new }
        format.json { render json: @game_user_movement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /game_user_movements/1
  # PATCH/PUT /game_user_movements/1.json
  def update
    respond_to do |format|
      if @game_user_movement.update(game_user_movement_params)
        format.html { redirect_to @game_user_movement, notice: 'Game user movement was successfully updated.' }
        format.json { render :show, status: :ok, location: @game_user_movement }
      else
        format.html { render :edit }
        format.json { render json: @game_user_movement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /game_user_movements/1
  # DELETE /game_user_movements/1.json
  def destroy
    @game_user_movement.destroy
    respond_to do |format|
      format.html { redirect_to game_user_movements_url, notice: 'Game user movement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game_user_movement
      @game_user_movement = GameUserMovement.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def game_user_movement_params
      params.require(:game_user_movement).permit(:game_id, :requester_id, :requestee_id, :card_no, :fail)
    end
end
