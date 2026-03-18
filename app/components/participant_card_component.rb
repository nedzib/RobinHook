require "base64"

class ParticipantCardComponent < ViewComponent::Base
  def initialize(participant:, round:, public_view: false)
    @participant = participant
    @round = round
    @public_view = ActiveModel::Type::Boolean.new.cast(public_view)
  end

  private

  def avatar_url
    @avatar_url ||= rubohash_avatar_url
  end

  def rubohash_avatar_url
    avatar_key = participant_seed.parameterize.presence || "participant"
    image = Rubohash.assemble!(avatar_key)

    "data:image/png;base64,#{Base64.strict_encode64(image.to_blob)}"
  end

  def participant_seed
    return participant.name.to_s unless participant.respond_to?(:id)
    return participant.name.to_s if participant.id.blank?

    "#{participant.id}-#{participant.name}"
  end

  attr_reader :participant, :round, :public_view
end
