require File.expand_path("#{File.dirname __FILE__}/../lilypad")

module Rack
  class Lilypad
    
    def initialize(app, api_key=nil, &block)
      @app = app
      ::Lilypad.config api_key, &block
    end
    
    def call(env)
      if ::Lilypad.limit?(env)
        r = Rack::Response.new
        r.redirect('/500.html')
        return r.finish
      end
      
      status, headers, body =
        begin
          @app.call env
        rescue Exception => e
          ::Lilypad.limit e, env
          ::Lilypad.notify e, env
          raise
        end
      
      if env['rack.exception']
        ::Lilypad.notify env['rack.exception'], env
      end
      
      [ status, headers, body ]
    end
  end
end