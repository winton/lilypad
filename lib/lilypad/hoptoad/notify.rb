class Lilypad
  class Hoptoad
    class Notify
      
      include Log::Methods
      
      def initialize(env, exception)
        @exception = exception
        @env = env
        
        http_start do |http|
          begin
            xml = XML.build *parse
            http.post @uri.path, xml, headers
          rescue Exception => e
          end
        end
        
        if env && success?
          env['hoptoad.notified'] = true
        end
        
        Config::Request.reset!
        log :notify, @response
        success?
      end
      
      private
      
      def backtrace
        regex = %r{^([^:]+):(\d+)(?::in `([^']+)')?$}
        @exception.backtrace.map do |line|
          _, file, number, method = line.match(regex).to_a
          Backtrace.new file, number, method
        end
      end

      def filter(hash)
        return hash if Config.filters.empty?
        hash.inject({}) do |acc, (key, val)|
          match = Config.filters.any? { |f| key.to_s =~ Regexp.new(f) }
          acc[key] = match ? "[FILTERED]" : val
          acc
        end
      end
      
      def headers
        {
          'Content-type' => 'text/xml',
          'Accept' => 'text/xml, application/xml'
        }
      end
      
      def http_start(&block)
        @uri = URI.parse Config.notify_url
        Net::HTTP.start @uri.host, @uri.port do |http|
          http.read_timeout = 5 # seconds
          http.open_timeout = 2 # seconds
          @response = yield http
        end
      end

      def parse
        env = filter ENV.to_hash.merge(@env || {})
        
        if @env
          request = Rack::Request.new @env
          params = filter request.params
          request_path = request.script_name + request.path_info
        else
          params = {}
          request_path = 'Internal'
        end
        
        [ backtrace, env, @exception, params, request_path ]
      end
      
      def success?
        @response.class.superclass == Net::HTTPSuccess
      end
      
      class Backtrace < Struct.new(:file, :number, :method)
      end
    end
  end
end