Rails.application.config.to_prepare do
  Dir[Rails.root.join('app/services/**/*.rb')].each { |file| require_dependency file }
end
