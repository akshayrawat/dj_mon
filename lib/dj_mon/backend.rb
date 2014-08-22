module DjMon
  module Backend
    BACKEND_METHODS = [:all, :failed, :active, :queued, :destroy, :retry, :limited]

    class << self
      def used_backend
        # it's hacky but, based on Delayed::Worker.backend= behavior
        @@used_backend ||= begin
          delayed_job_backend = Delayed::Worker.backend
          backend_name = delayed_job_backend.to_s.split("::")[-2]
          require "dj_mon/backend/#{backend_name.downcase}"
          "DjMon::Backend::#{backend_name}".constantize
        rescue
          raise "DjMon has no backend for '#{delayed_job_backend}'"
        end
      end

      BACKEND_METHODS << {:to => :used_backend}
      delegate *BACKEND_METHODS
    end
  end
end
