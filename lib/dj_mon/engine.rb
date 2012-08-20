module DjMon
  class Engine < Rails::Engine

    isolate_namespace DjMon

    config.dj_mon = ActiveSupport::OrderedOptions.new
    config.dj_mon.username = nil
    config.dj_mon.password = nil

    if Rails.version > "3.1"
      initializer "DJMon precompile hook" do |app|
        app.config.assets.precompile += ['dj_mon.js', 'dj_mon.css']
      end
    end

  end
end
