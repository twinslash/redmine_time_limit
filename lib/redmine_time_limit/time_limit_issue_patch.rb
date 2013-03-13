module TimeLimitIssuePatch
  def self.included(base)

    base.send(:include, InstanceMethods)
    attr_accessor :time_limit_allowed_ip

    base.class_eval do
      unloadable

      attr_accessor :time_limit_allowed_ip
      has_many :timers, :dependent => :destroy

      alias_method_chain :save_issue_with_child_records, :time_limit

    end
  end

  module InstanceMethods

    def save_issue_with_child_records_with_time_limit(params, existing_time_entry=nil)
      existing_time_entry ||= TimeEntry.new
      existing_time_entry.time_limit_allowed_ip = time_limit_allowed_ip

      save_issue_with_child_records_without_time_limit(params, existing_time_entry)
    end

    # define if timer can be started for this issue
    # allowed if:
    # current timer is not for this issue
    # AND
    # (status in time_limit_timer_working_status
    # OR
    # status can be changed to time_limit_timer_working_status)
    def timer_can_be_started?(user)
      settings = Setting.plugin_redmine_time_limit
      user.current_timer.try(:issue_id) != id &&
      (status_id.to_s == settings['time_limit_timer_working_status'] ||
        new_statuses_allowed_to(user) )
    end

  end
end
