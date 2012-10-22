class JournalTimeLimitObserver < ActiveRecord::Observer
  unloadable

  observe :journal
  
  def after_create(journal)
    timer = journal.issue.timers.find(:first, :conditions => {:user_id => User.current.id})
    if timer.nil?
      detail = journal.details.find(:first, :conditions => {:prop_key => 'status_id'})
      if detail && !journal.issue.timer_start_allowed?
        Timer.new(:issue_id => journal.issue.id, :user_id => User.current.id, :hours => 0).save
      end
    end
  end
end
