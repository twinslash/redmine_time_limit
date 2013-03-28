module TimersHelper
  def time_limit_protected_statuses_div
    settings = Setting.plugin_redmine_time_limit
    data = { :protected_status_ids => settings[:status_ids], :initial_status_id => @issue.status_id.to_s }

    content_tag(:div, nil, :id => 'protected_statuses', :data => "#{data.to_json}")
  end
end
