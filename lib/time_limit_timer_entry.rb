class TimeLimitTimerEntry
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  validate :internal_time_entries, :time_limit_timer_entries

  def initialize(user, issues, allowed_ip, params = {})
    @user = user
    @issues = issues
    @params = params
    @allowed_ip = allowed_ip

    @issues_by_id = {}
    @time_entries = {}
    @errors = HashWithIndifferentAccess.new
    @issues.map { |issue| @issues_by_id[issue.id] = issue }
    @issues_ids = issues.map(&:id)

    init_values
  end

  # define setter/getter methods
  def method_missing(method_name, *args, &block)
    match = method_name.to_s.match(/(?<method>time_entry_(comment|value|activity))_(?<id>\d+)(?<setter>=?)/)
    method, id, setter = match[:method], match[:id], match[:setter] if match
    if match && ['time_entry_value', 'time_entry_comment', 'time_entry_activity'].include?(method) && @issues_by_id[id.to_i]
      if setter == '=' # setter
        instance_variable_set("@#{method}_#{id}", args[0])
      else # getter
        instance_variable_get("@#{method}_#{id}")
      end
    else
      super
    end
  end

  def persisted?
    false
    # @params.present?
  end

  def valid?
    build_time_entries
    @errors = HashWithIndifferentAccess.new
    validate_time_limit_timer_entries
    validate_internal_time_entries
    @errors.empty?
  end

  def save
    valid? && save_destroy_entries
  end

  private

    # return sum of today timers for the issue/user
    def timer_sum(issue_id)
      current_timer = @user.timers.today.opened.where(:issue_id => issue_id).first
      current_spent = Time.now - current_timer.started_at if current_timer

      TimeLimitConverter.to_hours(@user.timers.today.where(:issue_id => issue_id).sum(:spent) + current_spent.to_i)
    end

    # setup values from defaults or params
    def init_values
      if @params.present?
        @params.each do |method, value|
          self.send(:"#{method}=", value)
        end
      else
        @issues.each do |issue|
          self.send(:"time_entry_value_#{issue.id}=", timer_sum(issue.id))
        end
      end
    end

    # check validity of timer entries
    def validate_time_limit_timer_entries
      @issues_ids.each do |id|
        sum = timer_sum(id)
        add_error(id, I18n.t(:tl_exceed_timer, :value => sum)) if instance_variable_get("@time_entry_value_#{id}").to_f > sum
      end
    end

    # check validity of redmine time entries
    def validate_internal_time_entries
      @time_entries.each do |id, time_entry|
        unless time_entry.valid?
          add_error(id, time_entry.errors.full_messages)
        end
      end
    end

    def build_time_entries
      @issues_ids.each do |id|
        @time_entries[id] = build_time_entry(id)
      end
    end

    def build_time_entry(id)
      issue = @issues_by_id[id]
      attr = HashWithIndifferentAccess.new(
        {"hours" => instance_variable_get("@time_entry_value_#{id}"),
         "comments" => instance_variable_get("@time_entry_comment_#{id}"),
         "activity_id" => instance_variable_get("@time_entry_activity_#{id}")
        }
      )

      time_entry = TimeEntry.new
      time_entry.project = issue.project
      time_entry.issue = issue
      time_entry.user = @user
      time_entry.spent_on = @user.today
      time_entry.time_limit_allowed_ip = @allowed_ip
      time_entry.skip_issue_status_validation = true
      time_entry.attributes = attr

      time_entry
    end

    def add_error(id, message)
      errors = @errors["time_entry_value_#{id}"] || []
      errors << message
      @errors["time_entry_value_#{id}"] = errors
    end

    # save time_entries and destroy timers
    def save_destroy_entries
      TimeEntry.transaction do
        @time_entries.each do |id, time_entry|
          time_entry.save!
          @user.timers.where(:issue_id => id).destroy_all
        end
        true
      end
    end

end
