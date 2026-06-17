require "test_helper"

class WebhookNotificationServiceTest < ActiveSupport::TestCase
  Response = Struct.new(:code, :body)

  test "returns false when webhook url is blank" do
    assert_equal false, WebhookNotificationService.new(nil).send_notification("hola", "https://example.com/pr")
  end

  test "returns true on a successful response" do
    request = nil
    fake_http = Object.new
    fake_http.define_singleton_method(:use_ssl=) { |_value| }
    fake_http.define_singleton_method(:request) do |req|
      request = req
      Response.new("200", "ok")
    end

    original_new = Net::HTTP.method(:new)
    Net::HTTP.define_singleton_method(:new) { |_host, _port| fake_http }

    begin
      result = WebhookNotificationService.new("https://example.com/hook").send_notification("hola <url_pr>", "https://example.com/pr")

      assert result
      assert_equal "application/json", request["Content-Type"]
      payload = JSON.parse(request.body)
      assert_equal "hola <https://example.com/pr|PR#pr>\nPrioridad: ℹ️ Normal", payload["text"]
      assert_nil payload["cardsV2"]
    ensure
      Net::HTTP.define_singleton_method(:new, original_new)
    end
  end

  test "replaces user mention and url placeholder" do
    request = nil
    fake_http = Object.new
    fake_http.define_singleton_method(:use_ssl=) { |_value| }
    fake_http.define_singleton_method(:request) do |req|
      request = req
      Response.new("200", "ok")
    end

    original_new = Net::HTTP.method(:new)
    Net::HTTP.define_singleton_method(:new) { |_host, _port| fake_http }

    begin
      message = "<user> ¡tienes un PR! Revisa <url_pr>"
      result = WebhookNotificationService.new("https://example.com/hook").send_notification(message, "https://example.com/pr", "123456789", "Juan")

      assert result
      payload = JSON.parse(request.body)
      expected_text = "<users/123456789> ¡tienes un PR! Revisa <https://example.com/pr|PR#pr>\nPrioridad: ℹ️ Normal"
      assert_equal expected_text, payload["text"]
      assert_nil payload["cardsV2"]
    ensure
      Net::HTTP.define_singleton_method(:new, original_new)
    end
  end

  test "falls back to participant name when google_user_id is missing" do
    request = nil
    fake_http = Object.new
    fake_http.define_singleton_method(:use_ssl=) { |_value| }
    fake_http.define_singleton_method(:request) do |req|
      request = req
      Response.new("200", "ok")
    end

    original_new = Net::HTTP.method(:new)
    Net::HTTP.define_singleton_method(:new) { |_host, _port| fake_http }

    begin
      message = "<user> ¡tienes un PR! Revisa <url_pr>"
      result = WebhookNotificationService.new("https://example.com/hook").send_notification(message, "https://example.com/pr", nil, "Juan")

      assert result
      payload = JSON.parse(request.body)
      expected_text = "Juan ¡tienes un PR! Revisa <https://example.com/pr|PR#pr>\nPrioridad: ℹ️ Normal"
      assert_equal expected_text, payload["text"]
    ensure
      Net::HTTP.define_singleton_method(:new, original_new)
    end
  end

  test "shows more fire emojis for higher priority" do
    request = nil
    fake_http = Object.new
    fake_http.define_singleton_method(:use_ssl=) { |_value| }
    fake_http.define_singleton_method(:request) do |req|
      request = req
      Response.new("200", "ok")
    end

    original_new = Net::HTTP.method(:new)
    Net::HTTP.define_singleton_method(:new) { |_host, _port| fake_http }

    begin
      message = "<user> ¡urgente! Revisa <url_pr>"
      result = WebhookNotificationService.new("https://example.com/hook").send_notification(message, "https://example.com/pr", nil, "Juan", 5)

      assert result
      payload = JSON.parse(request.body)
      expected_text = "Juan ¡urgente! Revisa <https://example.com/pr|PR#pr>\nPrioridad: 🔥 Urgente"
      assert_equal expected_text, payload["text"]
    ensure
      Net::HTTP.define_singleton_method(:new, original_new)
    end
  end

  test "returns false when the request raises an error" do
    fake_http = Object.new
    fake_http.define_singleton_method(:use_ssl=) { |_value| }
    fake_http.define_singleton_method(:request) do |_req|
      raise StandardError, "boom"
    end

    original_new = Net::HTTP.method(:new)
    Net::HTTP.define_singleton_method(:new) { |_host, _port| fake_http }

    begin
      result = WebhookNotificationService.new("https://example.com/hook").send_notification("hola", "https://example.com/pr")

      assert_equal false, result
    ensure
      Net::HTTP.define_singleton_method(:new, original_new)
    end
  end
end
