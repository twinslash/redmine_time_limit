class Timer < ActiveRecord::Base

  belongs_to :user
  belongs_to :issue

  scope :today, lambda { where('started_at >= ?', Date.today.to_time) }
  scope :opened, lambda { where(:stopped_at => nil) }
  scope :current_opened, lambda { |user_id| opened.where(:user_id => user_id) }

  validates_presence_of :user, :issue, :started_at
  validate :status_other_timers

  class << self
    # stop other opened timers
    # start a new one
    def start_new!(user, issue)
      timer = new(:user => user, :issue => issue, :started_at => Time.now)
      timer.stop_other_timers!
      timer.save!
    end

  end

  def stop!
    update_attributes!(:stopped_at => Time.now)
  end

  def stop_other_timers!
    Timer.current_opened(user.id).each do |timer|
      timer.stop!
    end
  end

  private

    # other timers should be closed
    def status_other_timers
      if Timer.current_opened(user.id).where("id <> ?", id).any?
        errors.add(:started_at, :tl_another_timers_are_opened)
      end
    end

end
