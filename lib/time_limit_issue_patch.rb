require_dependency 'issue'

module TimeLimitIssuePatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      has_many :timers
    end
  end

  module InstanceMethods
    def timer_start_allowed?
      status_ids = Setting.plugin_redmine_time_limit['status_ids'] || []
      User.current.allowed_to?(:timer_save, self.project) || status_ids.include?(self.status_id_was.to_s)
    end

    def timer_save_allowed?
      timer = self.timers.find(:first, :conditions => {:user_id => User.current.id})
      timer || self.timer_start_allowed?
    end
  end
end
