module RedmineTimeLimit
  class Hooks < Redmine::Hook::ViewListener

    render_on :view_issues_show_details_bottom, :partial => 'time_limit_issue_patch'

  end
end
