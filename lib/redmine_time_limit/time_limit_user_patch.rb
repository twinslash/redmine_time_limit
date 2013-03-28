module TimeLimitUserPatch
  def self.included(base)

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable

      has_many :timers, :dependent => :destroy

    end
  end

  module InstanceMethods

    def current_timer
      timers.today.opened.first
    end

    # total time from timer start
    def time_limit_total
      TimeLimitConverter.to_hours(Time.now - time_limit_begin)
    end

    # available time for timer
    def time_limit_balance
      value = (time_limit_total - time_limit_hours).round(2)
      if value >= -24
        value
      else
        'N/A'
      end
    end

  end
end
