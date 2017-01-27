module DjMon
  module AuthStrategy
    class BasicAuth
      def process controller
        controller.authenticate_or_request_with_http_basic do |username, password|
          username == Rails.configuration.dj_mon.username &&
          password == Rails.configuration.dj_mon.password
        end
      end
    end
  end
end
