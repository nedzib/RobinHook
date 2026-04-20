require "test_helper"

class GlobalRoundRobinSamplerServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "global-owner@example.com", password: "password123")
    @round = Round.create!(name: "Global round", user: @user)
    @subgroup = Subgroup.create!(name: "Backend", round: @round)
  end

  test "returns nil when there are no available participants" do
    Participant.create!(name: "Unavailable", round: @round, available: false)

    assert_nil GlobalRoundRobinSamplerService.new(@round).sample
  end

  test "samples across direct and subgroup participants" do
    Participant.create!(name: "Direct", round: @round, count: 2, available: true)
    subgroup_participant = Participant.create!(name: "Grouped", subgroup: @subgroup, count: 0, available: true)

    result = GlobalRoundRobinSamplerService.new(@round).sample

    assert_equal subgroup_participant, result
    assert_equal 1, subgroup_participant.reload.count
  end

  test "excludes the current user case-insensitively" do
    excluded = Participant.create!(name: "Ned", round: @round, count: 0, available: true)
    selected = Participant.create!(name: "Alice", subgroup: @subgroup, count: 0, available: true)

    result = GlobalRoundRobinSamplerService.new(@round, "ned").sample

    assert_equal selected, result
    assert_equal 1, selected.reload.count
    assert_equal 0, excluded.reload.count
  end
end
