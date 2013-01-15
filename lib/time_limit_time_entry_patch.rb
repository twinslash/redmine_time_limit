require 'date'

require_dependency 'time_entry'

module TimeLimitTimeEntryPatch
  def self.included(base)
    base.class_eval do
      unloadable

      validates_presence_of :comments

      validates_each :hours do |record, attr, value|
        if not value.nil? and record.new_record?
          user = User.current

          record.errors.add attr, 'invalid' if !user.time_limit_begin

          if !have_permissions?(user, record.project)
            record.errors.add attr, I18n.t(:too_much) if valid_time?(user, value)
            record.errors.add attr, I18n.t(:save_depricated) if status_tabu?(record.issue)
          end
        end
      end

      before_validation(:on => :create) do |record|
        record.spent_on = Date.today
      end

      after_create do |record|
        user = User.current
        user.time_limit_hours += record.hours
        user.save
      end
    end

    class << base

      def have_permissions?(usr, project)
        have = false
        have ||= usr.allowed_to?(:edit_own_time_entries, project)
        have ||= usr.allowed_to?(:no_time_limit, project)
      end

      def valid_time?(usr, value)
        value > (Time.now - usr.time_limit_begin).to_f / 3600 - usr.time_limit_hours
      end

      def status_tabu?(issue)
        status_ids = Setting.plugin_redmine_time_limit['status_ids'] || []
        status_ids.include?(issue.status_id_was.to_s) && status_ids.include?(issue.status_id.to_s)
      end
    end
  end
end
