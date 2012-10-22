require 'redmine'

require 'time_limit_tag_helper_patch'
require 'time_limit_time_entry_patch'
require 'time_limit_issue_patch'
require 'time_limit_application_controller_patch'

Rails.configuration.to_prepare do
  TimeEntry.send(:include, TimeLimitTimeEntryPatch)
  Issue.send(:include, TimeLimitIssuePatch)
  Redmine::MenuManager::MenuController.send(:include, Redmine::MenuManager::TimeLimitApplicationControllerPatch)
end

Redmine::Plugin.register :redmine_time_limit do
  name 'Time Limit plugin'
  author 'Just Lest'
  description ''
  version '0.2.2'

  permission :timer_save, :timer => :save

  settings :default => {'remote_ip_match' => '127.0.0.1',
                        'statuses' => nil},
           :partial => 'settings/time_limit_settings'
end

ActiveRecord::Base.observers << :journal_time_limit_observer
