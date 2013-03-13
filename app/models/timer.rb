class Timer < ActiveRecord::Base

  belongs_to :user
  belongs_to :issue

  scope :today, lambda { where('started_at >= ?', Date.today.to_time) }
  scope :opened, lambda { where(:stopped_at => nil) }

end
