require "net/http"
require "uri"
require "json"

class WebhookNotificationService
  def initialize(webhook_url)
    @webhook_url = webhook_url
  end

  def send_notification(message)
    return false if @webhook_url.blank?

    begin
      uri = URI.parse(@webhook_url)
      header = { 'Content-Type': "application/json" }
      body = { text: message }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      # Desactivar verificación SSL solo en desarrollo/local
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if Rails.env.development?

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body.to_json

      response = http.request(request)
      response.code.to_i.between?(200, 299)
    rescue => e
      Rails.logger.error("Error al enviar notificación al webhook: #{e.message}")
      false
    end
  end
end
