require 'redmine'

require_dependency 'redmine_time_limit/hooks'

require 'time_limit_tag_helper_patch'
require 'time_limit_time_entry_patch'
require 'time_limit_application_controller_patch'

Rails.configuration.to_prepare do
  TimeEntry.send(:include, TimeLimitTimeEntryPatch)
end

Redmine::Plugin.register :redmine_time_limit do
  name        'Redmine Time Limit plugin'
  author      "//Twinslash"
  description 'Plugin to limit time entries'
  version     '0.0.1'
  url         'https://github.com/twinslash/redmine_time_limit'
  author_url  'http://twinslash.com'

  permission :no_time_limit, :time_limit => :disable

  settings :default => {'remote_ip_match' => '127.0.0.1',
                        'statuses' => nil},
           :partial => 'settings/time_limit_settings'
end
