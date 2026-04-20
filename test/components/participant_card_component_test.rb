require "test_helper"

class ParticipantCardComponentTest < ActiveSupport::TestCase
  FakeImage = Struct.new(:blob) do
    def to_blob
      blob
    end
  end

  setup do
    @user = User.create!(email: "component-owner@example.com", password: "password123")
    @round = Round.create!(name: "Component round", user: @user)
  end

  test "uses the participant id and name when building the avatar seed" do
    participant = Participant.create!(name: "Ned Zib", round: @round)
    component = ParticipantCardComponent.new(participant: participant, round: @round)

    assert_equal "#{participant.id}-Ned Zib", component.send(:participant_seed)
  end

  test "falls back to the participant name when it has no id" do
    participant = Participant.new(name: "Ned Zib", round: @round)
    component = ParticipantCardComponent.new(participant: participant, round: @round)

    assert_equal "Ned Zib", component.send(:participant_seed)
  end

  test "builds a base64 avatar url" do
    participant = Participant.create!(name: "Avatar User", round: @round)
    component = ParticipantCardComponent.new(participant: participant, round: @round)

    original_assemble = Rubohash.method(:assemble!)
    Rubohash.define_singleton_method(:assemble!) { |_key| FakeImage.new("png-bytes") }

    begin
      assert_equal "data:image/png;base64,cG5nLWJ5dGVz", component.send(:avatar_url)
    ensure
      Rubohash.define_singleton_method(:assemble!, original_assemble)
    end
  end
end
