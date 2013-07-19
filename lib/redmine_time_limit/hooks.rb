module RedmineTimeLimit
  class Hooks < Redmine::Hook::ViewListener

    render_on :view_issues_show_details_bottom, :partial => 'time_limit_issue_patch'

  end

  class Hooks < Redmine::Hook::ViewListener
    def controller_issues_edit_before_save(context={ })
      Timer.stop_timers_if_status_is_changed(User.current, context[:issue])
    end
  end

end
