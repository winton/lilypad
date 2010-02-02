class Lilypad
  class Limit
    
    extend Log::Methods
    
    @@errors = {}
    @@expire = {}
    
    class <<self
      def errors
        @@errors
      end
      
      def expire
        @@expire
      end
      
      def limit(env)
        key = env_to_string(env)
        if key
          @@errors[key] ||= 0
          @@errors[key] += 1
          @@expire[key] = Time.now.utc + 10*60
        end
      end
      
      def limit?(env)
        key = env_to_string(env)
        limited = if key && @@errors[key] && @@expire[key]
          @@errors[key] > Config.limit && @@expire[key] > Time.now.utc
        else
          false
        end
        if limited
          begin
            raise "Error limit reached"
          rescue Exception => e
            ::Lilypad.notify(e, env)
          end
        end
        limited
      end
      
      def reset
        @@errors = {}
        @@expire = {}
      end
      
      def unlimit(env)
        key = env_to_string(env)
        if key
          @@errors[env_to_string(env)] = 0
        end
      end
      
      private
      
      def env_to_string(env)
        r = ::Rack::Request.new(env)
        if r.request_method && r.path_info && !r.path_info.empty?
          "#{r.request_method} #{r.path_info}"
        else
          nil
        end
      end
    end
  end
end