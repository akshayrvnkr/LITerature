require 'test_helper'

class GameUserMovementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game_user_movement = game_user_movements(:one)
  end

  test "should get index" do
    get game_user_movements_url
    assert_response :success
  end

  test "should get new" do
    get new_game_user_movement_url
    assert_response :success
  end

  test "should create game_user_movement" do
    assert_difference('GameUserMovement.count') do
      post game_user_movements_url, params: { game_user_movement: { card_no: @game_user_movement.card_no, fail: @game_user_movement.fail, game_id: @game_user_movement.game_id, requestee_id: @game_user_movement.requestee_id, requester_id: @game_user_movement.requester_id } }
    end

    assert_redirected_to game_user_movement_url(GameUserMovement.last)
  end

  test "should show game_user_movement" do
    get game_user_movement_url(@game_user_movement)
    assert_response :success
  end

  test "should get edit" do
    get edit_game_user_movement_url(@game_user_movement)
    assert_response :success
  end

  test "should update game_user_movement" do
    patch game_user_movement_url(@game_user_movement), params: { game_user_movement: { card_no: @game_user_movement.card_no, fail: @game_user_movement.fail, game_id: @game_user_movement.game_id, requestee_id: @game_user_movement.requestee_id, requester_id: @game_user_movement.requester_id } }
    assert_redirected_to game_user_movement_url(@game_user_movement)
  end

  test "should destroy game_user_movement" do
    assert_difference('GameUserMovement.count', -1) do
      delete game_user_movement_url(@game_user_movement)
    end

    assert_redirected_to game_user_movements_url
  end
end
