require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ClColmenaCourt
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.assets.paths << Rails.root.join("vendor", "assets", "bootstrap", "css")
    config.assets.paths << Rails.root.join("vendor", "assets", "bootstrap", "js")
    config.assets.paths << Rails.root.join("vendor", "assets", "bootstrap", "fonts")
    config.assets.paths << Rails.root.join("vendor", "assets", "plugins", "jQuery")
    config.assets.paths << Rails.root.join("vendor", "assets", "plugins", "iCheck")
    config.assets.paths << Rails.root.join("vendor", "assets", "plugins", "iCheck", "flat")
  end
end
