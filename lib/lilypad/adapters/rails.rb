class Lilypad
  module Rails
    
    def self.included(base)
      ENV['RACK_ENV'] = ENV['RAILS_ENV']
      if Lilypad.production? && !base.included_modules.include?(InstanceMethods)
        base.send :extend, ClassMethods
        base.send :include, InstanceMethods
        base.send :alias_method_chain, :rescue_action, :lilypad
        base.class_eval do
          class <<self
            alias_method_chain :call_with_exception, :lilypad
          end
        end
      end
    end
    
    module ClassMethods
      
      def call_with_exception_with_lilypad(env, exception)
        raise exception
      end
    end
    
    module InstanceMethods
      
      private
      
      def rescue_action_with_lilypad(exception)
        rescue_action_without_lilypad exception
        Config::Request.action params[:action]
        Config::Request.component params[:controller]
        raise exception
      end
    end
  end
end

ActionController::Base.send(:include, Lilypad::Rails)