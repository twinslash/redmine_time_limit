module TimeLimit
  module IssuesControllerPatch

    def self.included(base)
      base.class_eval do
        unloadable

        # skip this filter - it is necessary to prepare data
        skip_filter :authorize, :only => [:start_timer, :stop_timer]
        before_filter :time_limit_check_ip, :only => [:update]
        before_filter :time_limit_before_filters, :only => [:start_timer, :stop_timer]

        # check if timer can be started
        # fetch issues with started timer (which can change status to TODO and assigned to User.current)
        # update issues
        # stop previous timers
        # start new timer
        def start_timer
          @settings = Setting.plugin_redmine_time_limit
          @opened_timers = Timer.current_opened(User.current.id)

          if @issue.timer_can_be_started?(User.current)
            opened_issues = fetch_opened_issues

            if timer = Timer.create(:user => User.current, :issue => @issue, :started_at => Time.now)
              opened_issues.map(&:save)
              @opened_timers.map(&:stop!)

              @issue.init_journal(User.current)
              @issue.safe_attributes = { 'status_id' => @settings['time_limit_timer_working_status'] }
              @issue.save

              flash[:notice] = l(:tl_timer_started)
            else
              flash[:error] = l(:tl_timer_has_errors) + ' ' + timer.errors.inspect
            end
          else
            flash[:error] = l(:tl_timer_cannot_be_started)
          end
          redirect_to issue_path(@issue)
        end

        # check if timer can be stopped
        # check if issue's status can be changed and issue can be updated
        # update issue
        # stop timer
        def stop_timer
          if @issue.timer_can_be_stopped?(User.current)
            settings = Setting.plugin_redmine_time_limit
            allowed_status = @issue.new_statuses_allowed_to(User.current).map(&:id).include?(settings['time_limit_timer_start_status'].to_i)
            @issue.init_journal(User.current)
            @issue.safe_attributes = { 'status_id' => settings['time_limit_timer_start_status'] } if allowed_status
            can_be_saved = @issue.valid?

            if allowed_status && can_be_saved
              timer = @issue.timers.current_opened(User.current.id).first
              @issue.save!
              timer.stop!
              flash[:notice] = l(:tl_timer_stopped)
            else
              flash[:error] = l(:tl_issue_cannot_change_status) + '. ' + @issue.errors.full_messages.join('; ')
            end
          else
            flash[:error] = l(:tl_opened_timer_not_found)
          end
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

        # fetch issues (it should be not more then one) which
        # have active timer
        # and in status status 'Working' (defined in plugin setting time_limit_timer_working_status)
        # and can be moved to status 'TODO' (defined in plugin setting time_limit_timer_start_status)
        # and assigned to User.current
        def fetch_opened_issues
          issues = []
          @opened_timers.each do |timer|
            issue = timer.issue
            next if issue.assigned_to != User.current
            # init journal to leave a record that status is changed
            issue.init_journal(User.current)
            if (issue.status_id == @settings['time_limit_timer_working_status'].to_i &&
                issue.new_statuses_allowed_to(User.current).map(&:id).include?(@settings['time_limit_timer_start_status'].to_i))
              issue.safe_attributes = { 'status_id' => @settings['time_limit_timer_start_status'] }
              issues << issue if issue.valid?
            end
          end
          issues
        end

      end
    end
  end
end
