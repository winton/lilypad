module Rack
  class Lilypad
    
    def initialize(app, api_key=nil, &block)
      @app = app
      Lilypad api_key, &block
    end
    
    def call(env)
      status, headers, body =
        begin
          @app.call env
        rescue Exception => e
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