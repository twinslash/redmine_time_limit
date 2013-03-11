# Redmine Time Limit Plugin
Redmine Time Limit Plugin is used to monitor spent time by employees at the working place.

## Functionality
 * New right in 'Roles and permissions': 'Disable time limit'
 * You need to log in Redmine via 'allowed' IP-address for starting timer. Allowed IP-addresses are setup in plugin configuration.
 * Validation of time entries. It is forbidden to write off more time than the timer has.
 * Validation presence of comment for time entries.
 * Restriction to create time entries in some statuses.
 * Restriction to create time entries from 'not allowed' IP-addresses.

## The source of the plugin
https://github.com/twinslash/redmine_time_limit

## Installation
To install the plugin run clone from plugin directory (REDMINE/plugins):
```bash
cd REDMINE/plugins
git clone https://github.com/twinslash/redmine_time_limit.git
```

Migrate the database:
```bash
bundle exec rake redmine:plugins:migrate
```

Restart your Redmine server

## Uninstallation
Revert changes in database:
```bash
cd REDMINE
bundle exec rake redmine:plugins:migrate NAME=redmine_time_limit VERSION=0
```

Delete folder with the plugin
```bash
cd REDMINE/plugins
rm redmine_time_limit -rf
```

Restart your Redmine server

## Setting
NB: This plugin works only for those roles where the rights **'Edit time logs' and 'Edit own time logs' are disabled**.

If you need to have a role without restriction on time entries then enable the right for it 'Disable time limit' in the Administration-> Roles and Permissions.

In plugin configurations (Administration->Plugins->Redmine Time Limit Plugin):
 * Specify the IP-addresses which will be considered as 'allowed'. IP-addresses can be specified in the format of the subnet mask.
 * Specify a list of statuses which are prohibited for creating time entries. In case when a task status is changing user can create time entry if at least one of the statuses allows to do it.

## Usage
Once the user is logged in, he has a timer in the upper right corner with two numbers divided by '/'. The number on the left shows his time spent at the workplace. The number on the right shows the hours which can be written off. The user can not write off more time than total amount of time.

User can create time entry only on tasks in defined statuses. For example, there are three statuses TODO, Working, Finish. The plugin allows you to write off time only in Working  status. Then the order will be as follows:
 * User opens the task in TODO status and changes the status to Working
 * Block with time entry appears
 * Now user can enter time entry and submit the form
 * Then user can re-open the task and change the status to Finish, a block with time entry is displayed and it is allowed to create a new time entry.

If a user first time comes into Redmine from 'unapproved' IP-address, the timer will be set to -99 hours. The user will not be able to create time entry. If next time the same user comes from 'approved' IP-address then the timer will be reset. If the same user comes from 'unapproved' IP at that day then the timer is NOT reset (and the time will accumulate), but the user can not create time entry using this IP.
