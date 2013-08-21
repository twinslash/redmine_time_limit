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
    # ((status in time_limit_timer_working_status AND assigned_to User.current)
    #   OR
    #   (status in time_limit_timer_working_status AND status can be changed to time_limit_timer_working_status))
    def timer_can_be_started?(user)
      settings = Setting.plugin_redmine_time_limit
      user.current_timer.try(:issue_id) != id &&
        (
          (status_id.to_s == settings['time_limit_timer_working_status'] &&
            assigned_to_id == User.current.id) ||
          (status_id.to_s != settings['time_limit_timer_working_status'] &&
            time_limit_new_statuses_allowed_to(user, true).map(&:id).include?(settings['time_limit_timer_working_status'].to_i) )
        )
    end

    # define if timer is started for this user
    def timer_can_be_stopped?(user)
      timers.current_opened(User.current.id).any?
    end

    # this is light patched version for method Issue#new_statuses_allowed_to
    # it is used to get a list of possible new statuses
    # option 'as_assigned_user' allows to get list of statuses as if issue is assigned to user
    #
    # Returns an array of statuses that user is able to apply
    def time_limit_new_statuses_allowed_to(user=User.current, as_assigned_user=false)
      initial_status = status

      statuses = initial_status.find_new_statuses_allowed_to(
        user.admin ? Role.all : user.roles_for_project(project),
        tracker,
        author == user,
        as_assigned_user || assigned_to_id == user.id
        )
      statuses << initial_status unless statuses.empty?
      statuses = statuses.compact.uniq.sort
      blocked? ? statuses.reject {|s| s.is_closed?} : statuses
    end


  end
end
