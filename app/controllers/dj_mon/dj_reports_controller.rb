module DjMon
  class DjReportsController < ActionController::Base
    respond_to :json, :html
    layout 'dj_mon'

    before_filter :authenticate
    before_filter :set_api_version

    def index
    end

    def all
      respond_with DjReport.all_reports
    end

    def failed
      respond_with DjReport.failed_reports
    end

    def active
      respond_with DjReport.active_reports
    end

    def queued
      respond_with DjReport.queued_reports
    end

    def dj_counts
      respond_with DjReport.dj_counts
    end

    def settings
      respond_with DjReport.settings
    end

    def retry
      DjMon::Backend.retry params[:id]
      respond_to do |format|
        format.html { redirect_to root_url, notice: "The job has been queued for a re-run" }
        format.json { head(:ok) }
      end
    end

    def destroy
      DjMon::Backend.destroy params[:id]
      respond_to do |format|
        format.html { redirect_to root_url, notice: "The job was deleted" }
        format.json { head(:ok) }
      end
    end

    protected

    def authenticate
      if invalid_request
        render :text => 'Not Found', :status => '404'
        return false
      end
      authenticate_or_request_with_http_basic do |username, password|
        username == Rails.configuration.dj_mon.username &&
        password == Rails.configuration.dj_mon.password
      end
    end

    def set_api_version
      response.headers['DJ-Mon-Version'] = DjMon::VERSION
    end

    def invalid_request
      valid_ips = Rails.configuration.dj_mon.whitelist_ips
      return false if valid_ips.blank?
      valid_ips.select {|req| request.remote_ip.include?(req) }.empty?
    end

  end

end
