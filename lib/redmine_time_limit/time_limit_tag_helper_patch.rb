require 'date'

module ActionView
  module Helpers
    module TagHelper

      def content_tag_with_time_limit(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
        result = content_tag_without_time_limit(name, content_or_options_with_block, options, escape, &block)
        if options and options[:id] and options[:id] == 'loggedas'
          result += content_tag(:div, :style => "float: right; margin-right: 1em;", :id => "time_limit_indicator") do
                      "#{link_to(User.current.time_limit_total, day_reports_path)}/
                       #{User.current.time_limit_balance}".html_safe
                    end
        end
        result
      end
      alias_method_chain :content_tag, :time_limit

    end
  end
end
