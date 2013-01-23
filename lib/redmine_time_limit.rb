require_dependency 'redmine_time_limit/hooks'
require 'redmine_time_limit/time_limit_tag_helper_patch'
require 'redmine_time_limit/time_limit_time_entry_patch'
require 'redmine_time_limit/time_limit_application_controller_patch'

Rails.configuration.to_prepare do
  TimeEntry.send(:include, TimeLimitTimeEntryPatch)
end
