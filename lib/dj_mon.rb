require 'haml'
require 'dj_mon/version'
require 'dj_mon/engine'
require 'dj_mon/backend'

module DjMon
  class MissingAuthInformationError < StandardError
    def initialize message = nil
      super message || "You need to setup config.dj_mon.username and config.dj_mon.password in your application.rb"
    end
  end
end