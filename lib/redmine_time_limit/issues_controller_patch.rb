module TimeLimit
  module IssuesControllerPatch

    def self.included(base)
      base.class_eval do
        unloadable

        # skip this filter - it is necessary to prepare data
        skip_filter :authorize, :only => [:start_timer, :stop_timer]
        before_filter :time_limit_check_ip, :only => [:update]
        before_filter :time_limit_before_filters, :only => [:start_timer, :stop_timer]

        def start_timer
          # write logic
          redirect_to issue_path(@issue)
        end

        def stop_timer
          # write logic
          redirect_to issue_path(@issue)
        end

        private

        def time_limit_check_ip
          @issue.time_limit_allowed_ip = @allowed_ip
        end

        # define before filters only for new actions
        def time_limit_before_filters
          find_issue
          authorize
        end

      end
    end
  end
end
