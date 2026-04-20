require "test_helper"

class PublicSamplingTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "owner@example.com", password: "password123")
    @round = Round.create!(name: "Backend", hash_id: "publichash", user: @user)
    @alice = Participant.create!(name: "Alice", round: @round, count: 0, available: true)
    @bob = Participant.create!(name: "Bob", round: @round, count: 1, available: true)
  end

  test "POST /rounds/public assigns reviewer and returns plain text" do
    post rounds_public_path, params: { hash_id: @round.hash_id, me: "Alice", url: "https://github.com/acme/repo/pull/123" }

    assert_response :success
    assert_equal "text/plain; charset=utf-8", response.media_type + "; charset=utf-8"
    assert_equal "Bob", response.body
    assert_equal 2, @bob.reload.count
    assert_equal 0, @alice.reload.count
  end

  test "POST /rounds/public returns 422 when no participants are available" do
    @alice.update!(available: false)
    @bob.update!(available: false)

    post rounds_public_path, params: { hash_id: @round.hash_id, me: "Alice", url: "https://github.com/acme/repo/pull/123" }

    assert_response :unprocessable_entity
    assert_equal "No hay participantes disponibles.", response.body
  end

  test "POST /rounds/public treats underscores in me as spaces" do
    @alice.update!(name: "Alice Smith")

    post rounds_public_path, params: { hash_id: @round.hash_id, me: "Alice_Smith", url: "https://github.com/acme/repo/pull/123" }

    assert_response :success
    assert_equal "Bob", response.body
    assert_equal 2, @bob.reload.count
    assert_equal 0, @alice.reload.count
  end
end
