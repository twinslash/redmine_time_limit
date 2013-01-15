module RedmineTimeLimit
  class Hooks < Redmine::Hook::ViewListener

    def view_issues_show_details_bottom(context={})
      js = javascript_include_tag('redmine_time_limit.js', :plugin => 'redmine_time_limit')

      @settings = Setting.plugin_redmine_time_limit
      "#{js} <div id='protected_statuses' data='#{@settings[:status_ids].to_json}'></div>"
    end

  end
end
