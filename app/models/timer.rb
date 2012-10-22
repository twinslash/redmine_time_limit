class Timer < ActiveRecord::Base
  unloadable

  belongs_to :issue
  belongs_to :user
  
  def do_pause
    self.hours ||= 0
    self.hours += (Time.now - self.start).to_f / 3600 unless self.start.nil?
    self.start = nil
    self.save
  end
  
  def do_start
    self.do_pause
    self.start = DateTime.now
    self.save
  end
end
