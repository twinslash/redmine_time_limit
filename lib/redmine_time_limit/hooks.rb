module RedmineTimeLimit
  class Hooks < Redmine::Hook::ViewListener

    def view_issues_show_details_bottom(context={})
      issue = context[:issue]
      unless TimeEntry.have_permissions?(User.current, issue.project)
        js = javascript_include_tag('redmine_time_limit.js', :plugin => 'redmine_time_limit')

        @settings = Setting.plugin_redmine_time_limit
        data = { :protected_status_ids => @settings[:status_ids], :initial_status_id => issue.status_id.to_s }
        "<div id='protected_statuses' data='#{data.to_json}'></div> #{js}"
      end
    end

  end
end
