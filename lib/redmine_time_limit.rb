require_dependency 'redmine_time_limit/hooks'

require 'redmine_time_limit/time_limit_tag_helper_patch'
require 'redmine_time_limit/time_limit_time_entry_patch'
require 'redmine_time_limit/time_limit_issue_patch'

require 'redmine_time_limit/application_controller_patch'
require 'redmine_time_limit/issues_controller_patch'

Rails.configuration.to_prepare do
  ApplicationController.send(:include, TimeLimit::ApplicationControllerPatch)
  IssuesController.send(:include, TimeLimit::IssuesControllerPatch)

  TimeEntry.send(:include, TimeLimitTimeEntryPatch)
  Issue.send(:include, TimeLimitIssuePatch)
end
