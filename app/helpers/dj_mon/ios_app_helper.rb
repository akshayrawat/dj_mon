module DjMon
  module IosAppHelper
    def open_in_ios_app_link *options
      link_to options.shift, open_in_ios_app_url, *options
    end

    def open_in_ios_app_url
      params = {}
      params[:user] = Rails.configuration.dj_mon.username
      params[:password] = Rails.configuration.dj_mon.password
      params[:name] = request.domain.split(".").first.humanize
      params[:host] = dj_mon.root_url
      "dj-mon://open?#{params.map{|param, value| "#{param}=#{value}" }.join("&")}"
    end
  end
end
