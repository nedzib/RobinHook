require "net/http"
require "uri"
require "json"

class WebhookNotificationService
  def initialize(webhook_url)
    @webhook_url = webhook_url
  end

  def send_notification(message, group, url)
    return false if @webhook_url.blank?

    begin
      uri = URI.parse(@webhook_url)
      header = { "Content-Type": "application/json" }

      body = {
        "cardsV2": [
          {
            "cardId": "text-with-button",
            "card": {
              "sections": [
                {
                  "header": group,
                  "widgets": [
                    { "textParagraph": { "text": message } }
                  ]
                },
                {
                  "widgets": [
                    {
                      "buttonList": {
                        "buttons": [
                          {
                            "text": "Ir al PR",
                            "onClick": {
                              "openLink": { "url": url }
                            }
                          }
                        ]
                      }
                    }
                  ]
                }
              ]
            }
          }
        ]
      }

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
