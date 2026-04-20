require "test_helper"

class SubgroupTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "subgroup-owner@example.com", password: "password123")
    @round = Round.create!(name: "Subgroup round", user: @user)
  end

  test "is valid with a name and round" do
    subgroup = Subgroup.new(name: "Frontend", round: @round)

    assert subgroup.valid?
  end

  test "requires a name" do
    subgroup = Subgroup.new(round: @round)

    assert_not subgroup.valid?
    assert_includes subgroup.errors[:name], "can't be blank"
  end

  test "nullifies participant subgroup ids when destroyed" do
    subgroup = Subgroup.create!(name: "Backend", round: @round)
    participant = Participant.create!(name: "Alice", subgroup: subgroup)

    subgroup.destroy

    assert_nil participant.reload.subgroup_id
  end
end
