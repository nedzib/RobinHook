require "test_helper"

class RoundTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "round-test@example.com", password: "password123")
  end

  test "is valid with a name and optional webhook" do
    round = Round.new(name: "Team round", user: @user, web_hook: "https://example.com/hook")

    assert round.valid?
  end

  test "requires a name" do
    round = Round.new(user: @user)

    assert_not round.valid?
    assert_includes round.errors[:name], "can't be blank"
  end

  test "rejects an invalid webhook url" do
    round = Round.new(name: "Invalid webhook", user: @user, web_hook: "invalid-url")

    assert_not round.valid?
    assert_includes round.errors[:web_hook], "debe ser una URL válida"
  end

  test "generates a hash_id on create when missing" do
    round = Round.create!(name: "Hash round", user: @user)

    assert_not_nil round.hash_id
    assert_equal 12, round.hash_id.length
  end

  test "returns direct and subgroup participants in all_participants" do
    round = Round.create!(name: "All participants", user: @user)
    subgroup = round.subgroups.create!(name: "Backend")
    direct_participant = round.participants.create!(name: "Alice")
    subgroup_participant = Participant.create!(name: "Bob", subgroup: subgroup)

    assert_equal [ direct_participant, subgroup_participant ].sort_by(&:id), round.all_participants.sort_by(&:id)
  end
end
