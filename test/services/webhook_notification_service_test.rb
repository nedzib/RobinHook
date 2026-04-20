require "test_helper"

class WebhookNotificationServiceTest < ActiveSupport::TestCase
  Response = Struct.new(:code, :body)

  test "returns false when webhook url is blank" do
    assert_equal false, WebhookNotificationService.new(nil).send_notification("hola", "Global", "https://example.com/pr")
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
      result = WebhookNotificationService.new("https://example.com/hook").send_notification("hola", "Global", "https://example.com/pr")

      assert result
      assert_equal "application/json", request["Content-Type"]
      assert_includes request.body, "hola"
      assert_includes request.body, "https://example.com/pr"
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
      result = WebhookNotificationService.new("https://example.com/hook").send_notification("hola", "Global", "https://example.com/pr")

      assert_equal false, result
    ensure
      Net::HTTP.define_singleton_method(:new, original_new)
    end
  end
end
