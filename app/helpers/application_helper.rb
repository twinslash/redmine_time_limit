require_dependency 'application_helper'

module ApplicationHelper
  def link_to_if_authorized_with_time_limit(name, options = {}, html_options = nil, *parameters_for_method_reference)
    if options[:controller] == 'timelog' && options[:action] == 'edit' && options[:issue_id]
      if User.current.allowed_to?({:controller => options[:controller], :action => options[:action]}, @project)
        issue = Issue.find(options[:issue_id])
        timer = issue.timers.find(:first, :conditions => {:user_id => User.current.id})

        show_start = false
        show_pause = false
        show_save = false
        
        result = ''

        if timer.nil? || timer.start.nil?
          if issue.timer_start_allowed?
            html_options[:class] += ' timer-start-pause'
            result += link_to_remote('Start',
                                     {:url => {:controller => 'timers',
                                               :action => 'start',
                                               :issue_id => options[:issue_id]},
                                      :success => "$$('.timer-save').each(function (elem) { elem.show() }); $$('.timer-start-pause').each(function (elem) { elem.replace(request.responseText); });"},
                                     html_options) + ' '
          end
        else
          show_pause = true
        end

        if timer && timer.start
          html_options[:class] += ' timer-start-pause'
          result += link_to_remote('Pause',
                                   {:url => {:controller => 'timers',
                                             :action => 'pause',
                                             :issue_id => options[:issue_id]},
                                    :success => "$$('.timer-save').each(function (elem) { elem.show() }); $$('.timer-start-pause').each(function (elem) { elem.replace(request.responseText); });"},
                                   html_options) + ' '
        end

        html_options[:style] = 'display: none' unless issue.timer_save_allowed?
        html_options[:class].sub!(' timer-start-pause', '')
        html_options[:class] += ' timer-save'
        result += link_to(name, options, html_options)

        result
      end
    else
      link_to_if_authorized_without_time_limit(name, options, html_options, *parameters_for_method_reference)
    end
  end
  alias_method_chain :link_to_if_authorized, :time_limit
end
