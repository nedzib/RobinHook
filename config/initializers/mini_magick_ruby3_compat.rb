require "mini_magick"
require "pathname"
require "uri"

# Ruby 3 keyword-argument compatibility for MiniMagick 4.x.
# Rubohash depends on MiniMagick ~> 4.9, whose `Image.open` still forwards
# options as a positional Hash (`open(options)`), which raises on Ruby 3.
if defined?(MiniMagick::Image)
  module MiniMagick
    class Image
      class << self
        def open(path_or_url, ext = nil, options = {})
          options, ext = ext, nil if ext.is_a?(Hash)

          openable =
            if path_or_url.respond_to?(:open)
              path_or_url
            elsif path_or_url.respond_to?(:to_str) &&
                  %r{\A[A-Za-z][A-Za-z0-9+\-\.]*://} =~ path_or_url &&
                  (uri = URI.parse(path_or_url)).respond_to?(:open)
              uri
            else
              options = { binmode: true }.merge(options)
              Pathname(path_or_url)
            end

          ext ||= if openable.is_a?(URI::Generic)
                    File.extname(openable.path)
          else
                    File.extname(openable.to_s)
          end
          ext.sub!(/:.*/, "")

          openable.open(**options) { |file| read(file, ext) }
        end
      end
    end
  end
end
