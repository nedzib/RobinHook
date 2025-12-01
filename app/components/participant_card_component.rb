class ParticipantCardComponent < ViewComponent::Base
  def initialize(participant:, round:, public_view: false)
    @participant = participant
    @round = round
    @public_view = ActiveModel::Type::Boolean.new.cast(public_view)
  end

  private

  def avatar_url
    if defined?(Faker) && Faker.respond_to?(:Avatar)
      begin
        Faker::Avatar.image(slug: @participant.name, size: "80x80")
      rescue StandardError
        robohash_url
      end
    else
      robohash_url
    end
  end

  def robohash_url
    "https://robohash.org/#{ERB::Util.url_encode(@participant.name)}.png?size=80x80"
  end

  attr_reader :participant, :round, :public_view
end
