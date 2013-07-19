class Timer < ActiveRecord::Base

  belongs_to :user
  belongs_to :issue

  before_save :calculate_spent_time

  scope :today, lambda { where('started_at >= ?', Date.today.to_time) }
  scope :passed, lambda { where('started_at <= ?', Date.today.to_time) }
  scope :opened, lambda { where(:stopped_at => nil) }
  scope :current_opened, lambda { |user_id| opened.where(:user_id => user_id) }

  validates_presence_of :user, :issue, :started_at
  validate :find_other_opened_timers

  class << self
    # stop other opened timers
    # start a new one
    def start_new!(user, issue)
      timer = new(:user => user, :issue => issue, :started_at => Time.now)
      timer.stop_other_timers!
      timer.save
    end

    # when user creates a new time entry on issue then
    # => all user's timers created on this issue should be canceled (destroyed)
    # => if user had active timer and issue's status allows timers (status "Working") then start a new one
    def new_time_entry_was_created(user, issue)
      settings = Setting.plugin_redmine_time_limit
      should_be_started_new = where(issue_id: issue.id).current_opened(user.id).any?
      where(user_id: user.id).where(issue_id: issue.id).destroy_all
      start_new!(user, issue) if should_be_started_new && issue.status_id == settings['time_limit_timer_working_status'].to_i
    end

    # when issue's status is changed on status which not allows Timers - stop ALL timers
    def stop_timers_if_status_is_changed(user, issue)
      settings = Setting.plugin_redmine_time_limit
      if issue.status_id != settings['time_limit_timer_working_status'].to_i
        where(issue_id: issue.id).opened.all.map(&:stop!)
      end
    end

  end

  def stop!
    update_attributes(:stopped_at => Time.now)
  end

  def stop_other_timers!
    Timer.current_opened(user.id).each do |timer|
      timer.stop!
    end
  end

  def closed?
    !!stopped_at
  end

  private

    # check if current timer is not closed
    # other timers should be closed
    def find_other_opened_timers
      if !closed? && Timer.current_opened(user.id).where("id <> ?", id).any?
        errors.add(:started_at, :tl_another_timers_are_opened)
      end
    end

    def calculate_spent_time
      if stopped_at
        self.spent = stopped_at - started_at
      end
    end

end
