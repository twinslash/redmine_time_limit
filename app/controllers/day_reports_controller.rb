class DayReportsController < ApplicationController
  require 'time_limit_timer_entry'

  helper :timelog

  def index
    init_data
    if request.post? && @timer_entry.valid?
      @timer_entry.save
      flash[:notice] = l(:tl_saved)

      # reinit data after saving
      init_data
    end
  end

  private

    def init_data
      @issues = Issue.joins(:timers).
                      where("#{Timer.table_name}.user_id = ?", User.current.id).
                      where("#{Timer.table_name}.started_at >= ?", Date.today.to_time).
                      group("#{Issue.table_name}.id").
                      includes(:timers)
      @timer_entry = TimeLimitTimerEntry.new(User.current, @issues, @allowed_ip, params[:time_limit_timer_entry])
    end

end
