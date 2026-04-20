require "test_helper"

class RoundControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "round-owner@example.com", password: "password123")
    @round = Round.create!(name: "Platform", hash_id: "platform123", user: @user)
    sign_in @user
  end

  test "GET / renders the signed in user's rounds" do
    get root_path

    assert_response :success
    assert_includes response.body, @round.name
  end

  test "GET /rounds/new renders the form" do
    get new_round_path

    assert_response :success
  end

  test "POST /rounds creates a round with valid params" do
    assert_difference("Round.count", 1) do
      post rounds_path, params: { round: { name: "Backend", web_hook: "https://example.com/hook" } }
    end

    assert_redirected_to rounds_path
    assert_equal "Ronda creada exitosamente.", flash[:notice]
  end

  test "POST /rounds re-renders new with invalid params" do
    assert_no_difference("Round.count") do
      post rounds_path, params: { round: { name: "", web_hook: "not-a-url" } }
    end

    assert_response :success
  end

  test "GET /rounds/:id renders the private view" do
    get round_path(@round)

    assert_response :success
    assert_includes response.body, @round.name
  end

  test "GET /rounds/public renders the public view without authentication" do
    sign_out @user

    get rounds_public_path(hash_id: @round.hash_id)

    assert_response :success
    assert_includes response.body, @round.name
  end

  test "GET /rounds/:id/edit renders the edit form" do
    get edit_round_path(@round)

    assert_response :success
  end

  test "PATCH /rounds/:id updates a round with valid params" do
    patch round_path(@round), params: { round: { name: "Updated name", web_hook: "https://example.com/new-hook" } }

    assert_redirected_to rounds_path
    assert_equal "Updated name", @round.reload.name
  end

  test "PATCH /rounds/:id re-renders edit with invalid params" do
    patch round_path(@round), params: { round: { name: "", web_hook: "bad-url" } }

    assert_response :success
  end

  test "DELETE /rounds/:id destroys the round" do
    assert_difference("Round.count", -1) do
      delete round_path(@round)
    end

    assert_redirected_to rounds_path
    assert_equal "Ronda eliminada exitosamente.", flash[:notice]
  end
end
