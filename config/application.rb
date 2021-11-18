require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie" # but not sprockets!
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Casa
  class Application < Rails::Application
    config.action_mailer.preview_path ||= defined?(Rails.root) ? Rails.root.join("lib", "mailers", "previews") : nil
    config.eager_load_paths << Rails.root.join("app", "lib", "importers")
    config.load_defaults 6.0
    config.serve_static_assets = true
  end
end
