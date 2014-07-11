module TimeLimit
  module IssuesControllerPatch

    def self.included(base)
      base.class_eval do
        unloadable

        def save_issue_with_child_records_with_time_limit
          @time_entry ||= TimeEntry.new
          @time_entry.time_limit_allowed_ip = @issue.time_limit_allowed_ip

          save_issue_with_child_records_without_time_limit
        end

        alias_method_chain :save_issue_with_child_records, :time_limit

        before_filter :time_limit_check_ip, :only => [:update]

        private

        def time_limit_check_ip
          @issue.time_limit_allowed_ip = @allowed_ip
        end

      end
    end
  end
end
