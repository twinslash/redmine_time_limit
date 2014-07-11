module TimeLimitIssuePatch
  def self.included(base)

      attr_accessor :time_limit_allowed_ip

    base.class_eval do
      unloadable

      attr_accessor :time_limit_allowed_ip    
    end
  end
end