require 'rack/lilypad'

module Rack
  class Lilypad
    module Rails
      
      def self.included(base)
        ENV['RACK_ENV'] = ENV['RAILS_ENV']
      end
      
      private
      
      def rescue_action(exception)
        super
        request.env['rack.lilypad.component'] = params[:controller]
        request.env['rack.lilypad.action'] = params[:action]
        raise exception
      end
    end
  end
end

ActionController::Base.send(:include, Rack::Lilypad::Rails)