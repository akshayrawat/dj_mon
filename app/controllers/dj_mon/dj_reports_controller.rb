module DjMon
  class DjReportsController < ActionController::Base
    respond_to :json
    layout 'dj_mon'
    
    before_filter :authenticate, :if => lambda { DjMon::Engine.config.dj_mon.use_authenticate }
    after_filter :set_api_version

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
      redirect_to root_url, notice: "The job has been queued for a re-run" and return
    end
  
    def destroy
      DjMon::Backend.destroy params[:id]
      redirect_to root_url, notice: "The job was deleted" and return
    end
  
    protected

    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == Rails.configuration.dj_mon.username &&
        password == Rails.configuration.dj_mon.password
      end
    end
    
    def set_api_version
      response.headers['DJ-Mon-Version'] = DjMon::VERSION
    end

  end

end
