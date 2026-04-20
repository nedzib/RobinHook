require "test_helper"

class ParticipantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "participants-owner@example.com", password: "password123")
    @round = Round.create!(name: "Participants round", hash_id: "participants123", user: @user)
    @participant = Participant.create!(name: "Alice", round: @round, count: 1, available: true)
    @subgroup = Subgroup.create!(name: "Backend", round: @round)
    sign_in @user
  end

  test "GET /rounds/:round_id/participants/:id/edit renders the edit form" do
    get edit_round_participant_path(@round, @participant)

    assert_response :success
  end

  test "POST /rounds/:round_id/participants creates a participant" do
    assert_difference("Participant.count", 1) do
      post round_participants_path(@round), params: { participant: { name: "Bob", google_user_id: "123" } }
    end

    assert_redirected_to round_path(@round)
    assert_equal "Participante agregado exitosamente.", flash[:notice]
  end

  test "POST /rounds/:round_id/participants rejects invalid participants" do
    assert_no_difference("Participant.count") do
      post round_participants_path(@round), params: { participant: { name: "" } }
    end

    assert_redirected_to round_path(@round)
    assert_equal "Error al agregar participante.", flash[:alert]
  end

  test "PATCH /rounds/:round_id/participants/:id updates participant attributes" do
    patch round_participant_path(@round, @participant), params: { participant: { name: "Updated Alice" } }

    assert_redirected_to round_path(@round)
    assert_equal "Participante actualizado exitosamente.", flash[:notice]
    assert_equal "Updated Alice", @participant.reload.name
  end

  test "PATCH /rounds/:round_id/participants/:id increments the counter" do
    patch round_participant_path(@round, @participant), params: { increment: true }

    assert_redirected_to round_path(@round)
    assert_equal 2, @participant.reload.count
  end

  test "PATCH /rounds/:round_id/participants/:id decrements the counter when it is positive" do
    patch round_participant_path(@round, @participant), params: { decrement: true }

    assert_redirected_to round_path(@round)
    assert_equal 0, @participant.reload.count
  end

  test "PATCH /rounds/:round_id/participants/:id toggles availability and resets count when alone" do
    @participant.update!(available: false, count: 3)

    patch round_participant_path(@round, @participant), params: { available: true }

    assert_redirected_to round_path(@round)
    assert_equal true, @participant.reload.available
    assert_equal 0, @participant.reload.count
  end

  test "PATCH /rounds/:round_id/participants/:id restores availability using the minimum count" do
    other = Participant.create!(name: "Bob", round: @round, count: 2, available: true)
    @participant.update!(available: false, count: 9)

    patch round_participant_path(@round, @participant), params: { available: true }

    assert_redirected_to round_path(@round)
    assert_equal 2, @participant.reload.count
    assert_equal 2, other.reload.count
  end

  test "PATCH /rounds/:round_id/participants/:id moves a participant to a subgroup" do
    patch round_participant_path(@round, @participant), params: { subgroup_id: @subgroup.id }

    assert_redirected_to round_path(@round)
    assert_equal @subgroup.id, @participant.reload.subgroup_id
    assert_nil @participant.round_id
  end

  test "PATCH /rounds/:round_id/participants/:id returns a participant to the main round" do
    @participant.update!(subgroup: @subgroup, round: nil)

    patch round_participant_path(@round, @participant), params: { subgroup_id: 0 }

    assert_redirected_to round_path(@round)
    assert_nil @participant.reload.subgroup_id
    assert_equal @round.id, @participant.round_id
  end

  test "PATCH /rounds/:round_id/participants/:id redirects when subgroup does not exist" do
    patch round_participant_path(@round, @participant), params: { subgroup_id: 999_999 }

    assert_redirected_to round_path(@round)
    assert_equal "Subgrupo no encontrado.", flash[:alert]
  end

  test "DELETE /rounds/:round_id/participants/:id destroys the participant" do
    assert_difference("Participant.count", -1) do
      delete round_participant_path(@round, @participant)
    end

    assert_redirected_to round_path(@round)
  end
end
