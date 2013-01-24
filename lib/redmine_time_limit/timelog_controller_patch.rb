module TimeLimit
  module TimelogControllerPatch

    def self.included(base)
      base.class_eval do
        unloadable

        before_filter :time_limit_check_ip, :only => [:create, :update]

        private

        def time_limit_check_ip
          @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => User.current.today)
          @time_entry.time_limit_allowed_ip = @allowed_ip
        end

      end
    end
  end
end
