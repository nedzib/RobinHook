require "test_helper"

class CountersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "counters-owner@example.com", password: "password123")
    @round = Round.create!(name: "Counters round", user: @user)
    @subgroup = Subgroup.create!(name: "Backend", round: @round)
    @direct_participant = Participant.create!(name: "Alice", round: @round, count: 3)
    @grouped_participant = Participant.create!(name: "Bob", subgroup: @subgroup, count: 4)
    sign_in @user
  end

  test "POST /rounds/:round_id/counters/reset resets direct and subgroup counts" do
    post reset_round_counters_path(@round)

    assert_redirected_to round_path(@round)
    assert_equal 0, @direct_participant.reload.count
    assert_equal 0, @grouped_participant.reload.count
  end
end
