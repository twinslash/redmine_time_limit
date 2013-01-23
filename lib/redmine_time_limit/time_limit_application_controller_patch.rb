require 'date'

module Redmine
  module MenuManager
    module TimeLimitApplicationControllerPatch
      def MenuController.included(base)
        base.extend(Redmine::MenuManager::MenuController::ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do
          before_filter :time_limit
        end
      end

      module InstanceMethods
        def time_limit
          if User.current.logged?
            user = User.current

            check_ip = IpChecker.new(Setting.plugin_redmine_time_limit['remote_ip_match'])
            @allowed_ip = check_ip.trusted_ip?(request.remote_ip)

            update = false
            update ||= user.time_limit_hours.to_f >= 99 && @allowed_ip
            update ||= user.time_limit_begin == nil
            update ||= Date.parse(user.time_limit_begin.to_s) != Date.today
            if update
              user.time_limit_begin = Time.now
              user.time_limit_hours = @allowed_ip ? 0 : 99
              user.save
            end
          end
        end
      end
    end
  end
end
3
