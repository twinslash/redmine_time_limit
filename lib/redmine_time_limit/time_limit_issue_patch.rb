module TimeLimitIssuePatch
  def self.included(base)

    base.send(:include, InstanceMethods)
      attr_accessor :time_limit_allowed_ip

    base.class_eval do
      unloadable

      attr_accessor :time_limit_allowed_ip

      # alias_method_chain :save_issue_with_child_records, :time_limit
      alias_method_chain :update, :time_limit

    end
  end

  module InstanceMethods

    # def save_issue_with_child_records_with_time_limit(params, existing_time_entry=nil)
    def update_with_time_limit(params, existing_time_entry=nil)
      existing_time_entry ||= TimeEntry.new
      existing_time_entry.time_limit_allowed_ip = time_limit_allowed_ip

      save_issue_with_child_records_without_time_limit(params, existing_time_entry)
    end

  end
end