module DjMon
  module Backend
    module Mongoid
      module LimitedProxy
        class << self
          def method_missing(method, *args, &block)
            Rails.logger.debug "Limited method called."
            scope = ::DjMon::Backend::Mongoid.send(method, *args, &block)
            limit = Rails.configuration.dj_mon.results_limit
            limit.present? ? scope.desc(:_id).limit(limit) : scope.desc(:_id)
          end

          def respond_to?(method)
            super || ::DjMon::Backend::Mongoid.respond_to?(method)
          end
        end
      end

      class << self
        def limited
          LimitedProxy
        end

        def all
          Delayed::Job.all
        end

        def failed
          Delayed::Job.where(:failed_at.ne => nil)
        end

        def active
          Delayed::Job.where(:failed_at => nil, :locked_by.ne => nil)
        end

        def queued
          Delayed::Job.where(:failed_at => nil, :locked_by => nil)
        end

        def destroy id
          dj = Delayed::Job.find(id)
          dj.destroy if dj
        end

        def retry id
          dj = Delayed::Job.find(id)
          dj.unset :failed_at if dj
        end
      end
    end
  end
end
