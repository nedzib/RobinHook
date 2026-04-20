require "test_helper"

class RoundRobinSamplerServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "rr-owner@example.com", password: "password123")
    @round = Round.create!(name: "RR round", user: @user)
    @subgroup = Subgroup.create!(name: "Backend", round: @round)
  end

  test "returns nil when no participants are available" do
    Participant.create!(name: "Unavailable", subgroup: @subgroup, available: false)

    assert_nil RoundRobinSamplerService.new(@subgroup, "Someone").sample
  end

  test "selects the lowest count available participant and increments it" do
    high = Participant.create!(name: "High", subgroup: @subgroup, count: 3, available: true)
    low = Participant.create!(name: "Low", subgroup: @subgroup, count: 0, available: true)

    selected = RoundRobinSamplerService.new(@subgroup).sample

    assert_equal low, selected
    assert_equal 1, low.reload.count
    assert_equal 3, high.reload.count
  end

  test "excludes the current user case-insensitively when another candidate exists" do
    excluded = Participant.create!(name: "Ned", subgroup: @subgroup, count: 0, available: true)
    selected = Participant.create!(name: "Alice", subgroup: @subgroup, count: 0, available: true)

    result = RoundRobinSamplerService.new(@subgroup, "ned").sample

    assert_equal selected, result
    assert_equal 1, selected.reload.count
    assert_equal 0, excluded.reload.count
  end

  test "falls back to the current user when it is the only available candidate" do
    only = Participant.create!(name: "Ned", subgroup: @subgroup, count: 0, available: true)

    result = RoundRobinSamplerService.new(@subgroup, "ned").sample

    assert_equal only, result
    assert_equal 1, only.reload.count
  end
end
