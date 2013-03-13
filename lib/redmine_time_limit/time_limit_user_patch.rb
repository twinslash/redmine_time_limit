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

  end
end
