module DjMon
  class DjReport
    TIME_FORMAT = "%b %d %H:%M:%S"

    attr_accessor :delayed_job

    def initialize delayed_job
      self.delayed_job = delayed_job
    end

    def as_json(options={})
      { 
        id: delayed_job.id,
        payload: payload(delayed_job),
        priority: delayed_job.priority,
        attempts: delayed_job.attempts,
        queue: delayed_job.queue || "global",
        last_error_summary: delayed_job.last_error.to_s.truncate(30),
        last_error: delayed_job.last_error,
        failed_at: l_datetime(delayed_job.failed_at),
        run_at: l_datetime(delayed_job.run_at),
        created_at: l_datetime(delayed_job.created_at),
        failed: delayed_job.failed_at.present?
      }
    end

    def payload job
      job.payload_object.respond_to?(:object) ? job.payload_object.object.to_yaml : job.payload_object.to_yaml
    end

    class << self
      def reports_for jobs
        jobs.collect { |job| DjReport.new(job) }
      end

      def all_reports
        reports_for DjMon::Backend.all
      end

      def failed_reports
        reports_for DjMon::Backend.failed
      end

      def active_reports
        reports_for DjMon::Backend.active
      end

      def queued_reports
        reports_for DjMon::Backend.queued
      end

      def dj_counts
        [:all, :failed, :active, :queued].each_with_object({}) do |key, stack|
          stack[key] = DjMon::Backend.send(key).size
        end
      end

      def settings
        [
          :destroy_failed_jobs, :sleep_delay, :max_attempts,
          :max_run_time, :read_ahead, :delay_jobs
        ].each_with_object({}) do |key, stack|
          stack[key] = Delayed::Worker.send key
        end.merge!({
          delayed_job_version: Gem.loaded_specs["delayed_job"].version.version,
          dj_mon_version:      DjMon::VERSION
        })
      end
    end

    private
    def l_datetime time
      time.present? ? time.strftime(TIME_FORMAT) : ""
    end
  end

end
