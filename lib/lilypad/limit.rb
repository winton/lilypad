class Lilypad
  class Limit
    
    extend Log::Methods
    
    @@errors = {}
    
    class <<self
      def errors
        @@errors
      end
      
      def limit(e, env)
        key = env_to_string(env)
        if key
          @@errors[key] ||= 0
          if @@errors[key].class == Fixnum
            @@errors[key] += 1
            if @@errors[key] >= Config.limit
              @@errors[key] = Time.now.utc + 60
              env['lilypad'] = 'Error limit reached'
            end
          else
            @@errors[key] = Time.now.utc + 60
          end
        end
      end
      
      def limit?(env)
        key = env_to_string(env)
        if key && @@errors[key].class == Time && @@errors[key] > Time.now.utc
          env['lilypad'] = 'Error limit reached'
          true
        else
          false
        end
      end
      
      def reset
        @@errors = {}
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