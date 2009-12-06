class Lilypad
  module Rails
    
    def self.included(base)
      ENV['RACK_ENV'] = ENV['RAILS_ENV']
      base.send(:include, LilypadMethods) if Lilypad.production?
    end
    
    module LilypadMethods
      
      private
      
      def rescue_action_without_handler(exception)
        super
        Config::Request.action params[:action]
        Config::Request.component params[:controller]
        raise exception
      end
    end
  end
end

ActionController::Base.send(:include, Lilypad::Rails)