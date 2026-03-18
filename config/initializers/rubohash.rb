require "rubohash"

Rubohash.configure do |config|
  config.default_set = "set4"
  config.use_default_set = true
  config.use_background = false
  config.default_format = "png"
  config.mounted = true
end
