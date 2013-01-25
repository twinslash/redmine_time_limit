require 'date'

module ActionView
  module Helpers
    module TagHelper

      def content_tag_with_time_limit(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
        result = content_tag_without_time_limit(name, content_or_options_with_block, options, escape, &block)
        if options and options[:id] and options[:id] == 'loggedas'
          time_limit_total = (Time.now - User.current.time_limit_begin).to_f / 3600
          time_limit = if (value = time_limit_total - User.current.time_limit_hours) >= -24
            (value * 100).floor / 100.0
          else
            'N/A'
          end

          result += content_tag(:div, :style => "float: right; margin-right: 1em;", :id => "time_limit_indicator") do
                      "#{(time_limit_total * 100).floor / 100.0} /
                       #{time_limit}"
                    end
        end
        result
      end
      alias_method_chain :content_tag, :time_limit

    end
  end
end
