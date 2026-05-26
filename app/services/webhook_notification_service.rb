require "net/http"
require "uri"
require "json"

class WebhookNotificationService
  def initialize(webhook_url)
    @webhook_url = webhook_url
  end

  def send_notification(message, url, google_user_id = nil, participant_name = nil)
    return false if @webhook_url.blank?

    begin
      uri = URI.parse(@webhook_url)
      header = { "Content-Type": "application/json" }

      user_mention = if google_user_id.present?
                       "<users/#{google_user_id}>"
                     elsif participant_name.present?
                       participant_name
                     else
                       "<user>"
                     end

      message = message.gsub("<user>", user_mention)
      message = message.gsub("<url_pr>", "<#{url}|Pull Request>")

      body = { "text": message }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if Rails.env.development?

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body.to_json

      response = http.request(request)
      Rails.logger.info("Webhook response: #{response.code} #{response.body}")
      response.code.to_i.between?(200, 299)
    rescue => e
      Rails.logger.error("Error al enviar notificación al webhook: #{e.message}")
      false
    end
  end
end
