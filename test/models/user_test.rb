require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "has many rounds" do
    user = User.create!(email: "user-rounds@example.com", password: "password123")
    round = Round.create!(name: "Owned round", user: user)

    assert_equal [ round ], user.rounds
  end
end
