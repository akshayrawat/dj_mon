module DjMon
  class Engine < Rails::Engine

    isolate_namespace DjMon

    config.dj_mon = ActiveSupport::OrderedOptions.new
    config.dj_mon.username = "dj_mon"
    config.dj_mon.password = "password"
    config.dj_mon.api_auth_strategy = DjMon::AuthStrategy::BasicAuth
    config.dj_mon.web_auth_strategy = DjMon::AuthStrategy::None

    if Rails.version > "3.1"
      initializer "DJMon precompile hook" do |app|
        app.config.assets.precompile += ['dj_mon.js', 'dj_mon.css']
      end
    end

  end
end
