require 'redmine'
require 'redmine_time_limit'

Redmine::Plugin.register :redmine_time_limit do
  name        'Redmine Time Limit plugin'
  author      "//Twinslash"
  description 'Plugin to limit time entries'
  version     '0.0.1'
  url         'https://github.com/twinslash/redmine_time_limit'
  author_url  'http://twinslash.com'

  permission :no_time_limit, :time_limit => :disable
  permission :time_limit_timer, { :issues => [ :start_timer, :stop_timer ] }, :public => true

  settings :default => {'remote_ip_match' => '127.0.0.1',
                        'statuses' => nil},
           :partial => 'settings/time_limit_settings'
end
