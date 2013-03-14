class Timer < ActiveRecord::Base

  belongs_to :user
  belongs_to :issue

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

end
