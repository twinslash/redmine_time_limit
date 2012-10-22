require 'date'

require_dependency 'time_entry'

module TimeLimitTimeEntryPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable

      validates_presence_of :comments

      validates_each :hours do |record, attr, value|
        if not value.nil? and record.new_record?
          user = User.current
          if user.time_limit_begin
            time_limit = (Time.now - user.time_limit_begin).to_f / 3600 - user.time_limit_hours
            record.errors.add attr, 'too much' if value > time_limit  && !user.allowed_to?(:edit_own_time_entries, record.project)
          else
            record.errors.add attr, 'invalid'
          end
        end
      end

      validates_each :issue_id do |record, attr, value|
        if record.new_record? && record.issue
          record.errors.add attr, 'invalid' unless record.issue.timer_save_allowed?
        end
      end

      before_validation(:on => :create) do |record|
        record.spent_on = Date.today
      end

      after_create do |record|
        User.current.time_limit_hours += record.hours
        User.current.save
        timer = record.issue.timers.find(:first, :conditions => {:user_id => User.current.id})
        timer.delete if timer
      end

      alias_method_chain :initialize, :time_limit unless method_defined?(:initialize_with_time_limit)
    end
  end

  module InstanceMethods
    def initialize_with_time_limit(attrs = nil)
      if attrs && attrs[:hours].nil? && attrs[:issue]
        timer = attrs[:issue].timers.find(:first, :conditions => {:user_id => User.current.id})
        if timer
          hours = timer.hours
          hours += (Time.now - timer.start).to_f / 3600 if timer.start
          attrs[:hours] = (hours * 100).floor / 100.0 if hours > 0.01
        end
      end
      initialize_without_time_limit(attrs) do
        yield(self) if block_given?
      end
    end
  end
end
