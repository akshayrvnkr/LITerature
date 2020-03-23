require "application_system_test_case"

class GameUserMovementsTest < ApplicationSystemTestCase
  setup do
    @game_user_movement = game_user_movements(:one)
  end

  test "visiting the index" do
    visit game_user_movements_url
    assert_selector "h1", text: "Game User Movements"
  end

  test "creating a Game user movement" do
    visit game_user_movements_url
    click_on "New Game User Movement"

    fill_in "Card no", with: @game_user_movement.card_no
    check "Fail" if @game_user_movement.fail
    fill_in "Game", with: @game_user_movement.game_id
    fill_in "Requestee", with: @game_user_movement.requestee_id
    fill_in "Requester", with: @game_user_movement.requester_id
    click_on "Create Game user movement"

    assert_text "Game user movement was successfully created"
    click_on "Back"
  end

  test "updating a Game user movement" do
    visit game_user_movements_url
    click_on "Edit", match: :first

    fill_in "Card no", with: @game_user_movement.card_no
    check "Fail" if @game_user_movement.fail
    fill_in "Game", with: @game_user_movement.game_id
    fill_in "Requestee", with: @game_user_movement.requestee_id
    fill_in "Requester", with: @game_user_movement.requester_id
    click_on "Update Game user movement"

    assert_text "Game user movement was successfully updated"
    click_on "Back"
  end

  test "destroying a Game user movement" do
    visit game_user_movements_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Game user movement was successfully destroyed"
  end
end
