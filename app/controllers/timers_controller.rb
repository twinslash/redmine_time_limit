class TimersController < ApplicationController
  unloadable
  layout 'base'

  helper :timelog

  def start
    if params[:issue_id]
      @issue = Issue.find(params[:issue_id])
      timer = @issue.timers.find(:first, :conditions => {:user_id => User.current.id})
      
      if @issue.timer_start_allowed?
        timers = Timer.find(:all, :conditions => ['user_id = ? AND issue_id != ?', User.current.id, @issue.id])
        timers.each do |t|
          t.do_pause
        end

        timer = Timer.new(:issue_id => @issue.id, :user_id => User.current.id) if timer.nil?
        timer.do_start
      end

      render :layout => false
    else
      render :nothing => true
    end
  end
  
  def pause
    if params[:issue_id]
      @issue = Issue.find(params[:issue_id])
      timer = @issue.timers.find(:first, :conditions => {:user_id => User.current.id})
      
      if timer
        timer.do_pause
      end

      render :layout => false
    else
      render :nothing => true
    end
  end
  
  def post
    @timers = Timer.find(:all, :conditions => {:user_id => User.current})
    @time_entries = []
    if request.post?
      valid_all = true
      hours_all = 0.0
      for timer_id, parameters in params[:time_entries]
        timer = @timers.select {|t| t.id == timer_id.to_i}.first
        if timer
          time_entry = TimeEntry.new(:project => timer.issue.project, :issue => timer.issue, :user => User.current, :spent_on => Date.today)
          time_entry.attributes = parameters
          valid = time_entry.valid?
          valid_all &&= valid
          @time_entries << time_entry
          hours_all += time_entry.hours
        end
      end
      if User.current.time_limit_begin
        time_limit = (Time.now - User.current.time_limit_begin).to_f / 3600 - User.current.time_limit_hours
        @time_limit_exceeded = hours_all > time_limit
      end
      if valid_all && !@time_limit_exceeded
        @time_entries.each {|t| t.save }
        redirect_to :controller => 'my', :action => 'page'
      end
    end
  end
end
