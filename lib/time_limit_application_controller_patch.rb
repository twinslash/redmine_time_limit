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
      # #===========================
      # request = stub_model(Request, remote_ip: '127.0.0.1')
      # request.persisted? # => true

      # request = stub(remote_ip: '127.0.0.1')


      # class Request
      #   def remote_ip
      #     '127.0.0.1'
      #   end
      # end
      # request = Request.new

      # #===========================

      module InstanceMethods
        def time_limit
          if User.current.logged?
            p '======================'
            p request.remote_ip
            p '======================'
            p request
            p '======================'
            user = User.current
            local = request.remote_ip.match(Setting.plugin_redmine_time_limit['remote_ip_match'])
            update = false
            update ||= user.time_limit_hours.to_f >= 99 && local
            update ||= user.time_limit_begin == nil
            update ||= Date.parse(user.time_limit_begin.to_s) != Date.today
            if update
              user.time_limit_begin = Time.now
              user.time_limit_hours = local ? 0 : 99
              user.save

              timers = Timer.find(:all, :conditions => ['user_id = ? AND (start < ? OR start IS NULL)',
                                                        user.id, Date.today])
              timers.each {|t| t.delete}
            end
          end
        end
      end
    end
  end
end
