require 'builder'
require 'net/http'
require 'rack'

lib = File.dirname(__FILE__)
require "#{lib}/lilypad/config"
require "#{lib}/lilypad/config/request"
require "#{lib}/lilypad/log"
require "#{lib}/lilypad/hoptoad/deploy"
require "#{lib}/lilypad/hoptoad/notify"
require "#{lib}/lilypad/hoptoad/xml"
require "#{lib}/rack/lilypad"

class Lilypad
  class <<self
    
    def active?
      Config.api_key
    end
    
    def config(api_key=nil, &block)
      if api_key
        Config.api_key api_key
      end
      if block_given?
        Config.class_eval &block
      end
    end
    
    def deploy(options)
      if active? && production?
        Hoptoad::Deploy.new options
      end
    end
    
    def notify(exception, env=nil)
      if active? && production?
        Hoptoad::Notify.new env, exception
      end
    end
    
    def production?
      Config.environments.include? ENV['RACK_ENV']
    end
  end
end

def Lilypad(api_key=nil, &block)
  Lilypad.config api_key, &block
end