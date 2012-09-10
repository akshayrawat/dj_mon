module DjMon
  module Backend
    module ActiveRecord
      class << self
        def all
          Delayed::Job.scoped
        end

        def failed
          Delayed::Job.where('delayed_jobs.failed_at IS NOT NULL').last(500)
        end

        def active
          Delayed::Job.where('delayed_jobs.failed_at IS NULL AND delayed_jobs.locked_by IS NOT NULL').last(500)
        end

        def queued
          Delayed::Job.where('delayed_jobs.failed_at IS NULL AND delayed_jobs.locked_by IS NULL').last(500)
        end

        def destroy id
          dj = Delayed::Job.find(id)
          dj.destroy
        end

        def retry id
          dj = Delayed::Job.find(id)
          dj.update_attributes({ failed_at: nil })
        end
      end
    end
  end
end
