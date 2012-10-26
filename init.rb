require 'redmine'

require 'time_limit_tag_helper_patch'
require 'time_limit_time_entry_patch'
require 'time_limit_application_controller_patch'

Rails.configuration.to_prepare do
  TimeEntry.send(:include, TimeLimitTimeEntryPatch)
  #Redmine::MenuManager::MenuController.send(:include, Redmine::MenuManager::TimeLimitApplicationControllerPatch)
end

Redmine::Plugin.register :redmine_time_limit do
  name 'Time Limit plugin'
  author 'Twinslash Inc.'
  description 'Plugin for limited time'
  version '0.0.1'

  #permission :timer_save, :timer => :save

  settings :default => {'remote_ip_match' => '127.0.0.1',
                        'statuses' => nil},
           :partial => 'settings/time_limit_settings'
end

#ActiveRecord::Base.observers << :journal_time_limit_observer
