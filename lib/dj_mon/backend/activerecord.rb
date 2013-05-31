module DjMon
  module Backend
    module ActiveRecord
      class << self
        def all
          Delayed::Job.all
        end

        def failed
          Delayed::Job.where('failed_at IS NOT NULL')
        end

        def active
          Delayed::Job.where('failed_at IS NULL AND locked_by IS NOT NULL')
        end

        def queued
          Delayed::Job.where('failed_at IS NULL AND locked_by IS NULL')
        end

        def destroy id
          dj = Delayed::Job.find(id)
          dj.destroy if dj
        end

        def retry id
          dj = Delayed::Job.find(id)
          dj.update_attribute :failed_at, nil if dj
        end
      end
    end
  end
end
