require "test_helper"

class SamplingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "samplings-owner@example.com", password: "password123")
    @round = Round.create!(name: "Samplings round", hash_id: "sampling123", user: @user)
    @subgroup = Subgroup.create!(name: "backend", round: @round)
    @direct_participant = Participant.create!(name: "Alice", round: @round, count: 0, available: true)
    @subgroup_participant = Participant.create!(name: "Bob", subgroup: @subgroup, count: 0, available: true)
  end

  test "POST /rounds/:round_id/samplings redirects to the private round after global sampling" do
    post round_global_samplings_path(@round), params: { current_user_name: "Alice" }

    assert_redirected_to round_path(@round)
    assert_equal "Bob ha sido seleccionado.", flash[:notice]
  end

  test "POST /rounds/:round_id/samplings redirects to the public round when requested" do
    post round_global_samplings_path(@round), params: { current_user_name: "Alice", public_view: "true" }

    assert_redirected_to rounds_public_path(hash_id: @round.hash_id)
  end

  test "POST /rounds/:round_id/subgroups/:subgroup_id/samplings samples from a subgroup" do
    post round_subgroup_samplings_path(@round, @subgroup), params: { current_user_name: "Alice" }

    assert_redirected_to round_path(@round)
    assert_equal "Bob ha sido seleccionado.", flash[:notice]
  end

  test "POST /rounds/:round_id/samplings sets an alert when there are no available participants" do
    @direct_participant.update!(available: false)
    @subgroup_participant.update!(available: false)

    post round_global_samplings_path(@round), params: { current_user_name: "Alice" }

    assert_redirected_to round_path(@round)
    assert_equal "No hay participantes disponibles.", flash[:alert]
  end

  test "POST /rounds/:round_id/samplings sends a webhook notification when configured" do
    @round.update!(web_hook: "https://example.com/hook")
    chat_parameters = nil
    fake_client = Object.new
    fake_client.define_singleton_method(:chat) do |parameters:|
      chat_parameters = parameters
      { "choices" => [ { "message" => { "content" => "<user> revisa este PR" } } ] }
    end
    notifier_calls = []
    fake_notifier = Object.new
    fake_notifier.define_singleton_method(:send_notification) do |message, group, url|
      notifier_calls << [ message, group, url ]
      true
    end
    previous_token = ENV["OPENAPI_ACCESS_TOKEN"]
    ENV["OPENAPI_ACCESS_TOKEN"] = "test-token"
    original_client_new = OpenAI::Client.method(:new)
    original_notifier_new = WebhookNotificationService.method(:new)
    OpenAI::Client.define_singleton_method(:new) { |**_kwargs| fake_client }
    WebhookNotificationService.define_singleton_method(:new) { |_webhook_url| fake_notifier }

    begin
        post round_global_samplings_path(@round), params: { current_user_name: "Alice", pr_url: "https://example.com/pr/1" }
    ensure
      ENV["OPENAPI_ACCESS_TOKEN"] = previous_token
      OpenAI::Client.define_singleton_method(:new, original_client_new)
      WebhookNotificationService.define_singleton_method(:new, original_notifier_new)
    end

    assert_redirected_to round_path(@round)
    assert_equal "Bob ha sido seleccionado y se ha enviado la notificación.", flash[:notice]
    assert_equal "gpt-4.1-nano", chat_parameters[:model]
    assert_equal [ [ "Bob! revisa este PR", "Global", "https://example.com/pr/1" ] ], notifier_calls
  end
end
