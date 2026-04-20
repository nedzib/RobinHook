require "test_helper"

class SubgroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "subgroups-owner@example.com", password: "password123")
    @round = Round.create!(name: "Subgroups round", user: @user)
    @subgroup = Subgroup.create!(name: "Backend", round: @round)
    sign_in @user
  end

  test "POST /rounds/:round_id/subgroups creates a subgroup" do
    assert_difference("Subgroup.count", 1) do
      post round_subgroups_path(@round), params: { subgroup: { name: "Frontend" } }
    end

    assert_redirected_to round_path(@round)
  end

  test "POST /rounds/:round_id/subgroups redirects with an alert for invalid params" do
    assert_no_difference("Subgroup.count") do
      post round_subgroups_path(@round), params: { subgroup: { name: "" } }
    end

    assert_redirected_to round_path(@round)
    assert_match(/Error al crear subgrupo/, flash[:alert])
  end

  test "DELETE /rounds/:round_id/subgroups/:id moves participants back to the round" do
    participant = Participant.create!(name: "Alice", subgroup: @subgroup)

    assert_difference("Subgroup.count", -1) do
      delete round_subgroup_path(@round, @subgroup)
    end

    assert_redirected_to round_path(@round)
    assert_nil participant.reload.subgroup_id
    assert_equal @round.id, participant.round_id
  end
end
