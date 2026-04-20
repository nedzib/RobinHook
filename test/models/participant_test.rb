require "test_helper"

class ParticipantTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "participant-owner@example.com", password: "password123")
    @round = Round.create!(name: "Participant round", user: @user)
  end

  test "is valid when it belongs to a round" do
    participant = Participant.new(name: "Alice", round: @round, count: 0)

    assert participant.valid?
  end

  test "requires a name" do
    participant = Participant.new(round: @round)

    assert_not participant.valid?
    assert_includes participant.errors[:name], "can't be blank"
  end

  test "requires belonging to a round or subgroup" do
    participant = Participant.new(name: "Orphan")

    assert_not participant.valid?
    assert_includes participant.errors[:base], "El participante debe pertenecer a una ronda o a un subgrupo"
  end

  test "rejects negative counts" do
    participant = Participant.new(name: "Alice", round: @round, count: -1)

    assert_not participant.valid?
    assert_includes participant.errors[:count], "must be greater than or equal to 0"
  end

  test "broadcasts count updates" do
    participant = Participant.create!(name: "Alice", round: @round, count: 0)
    captured = nil

    participant.define_singleton_method(:broadcast_replace_to) { |*args, **kwargs| captured = [ args, kwargs ] }
    participant.send(:broadcast_counter)

    assert_equal [ "count" ], captured.first
    assert_equal "#{participant.id}_count", captured.last[:target]
    assert_equal "round/count", captured.last[:partial]
  end

  test "broadcasts availability updates" do
    participant = Participant.create!(name: "Alice", round: @round, count: 0)
    captured = nil

    participant.define_singleton_method(:broadcast_replace_to) { |*args, **kwargs| captured = [ args, kwargs ] }
    participant.send(:broadcast_available)

    assert_equal [ "count" ], captured.first
    assert_equal "#{participant.id}_available", captured.last[:target]
    assert_equal "round/available", captured.last[:partial]
  end
end
