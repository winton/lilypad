class Lilypad
  class Hoptoad
    class Deploy
      
      include Config::Methods
      include Log::Methods
      
      def initialize(options)
        @options = options
        
        begin
          post
        rescue Exception => e
        end
        
        log :debug, @response
        success?
      end
      
      private
      
      def params
        {
          'api_key' => api_key,
          'deploy[local_username]' => @options[:username],
          'deploy[rails_env]' => @options[:environment],
          'deploy[scm_revision]' => @options[:revision],
          'deploy[scm_repository]' => @options[:repository]
        }
      end
      
      def post
        url = URI.parse Config.deploy_url
        @response = Net::HTTP.post_form url, params
      end
      
      def success?
        @response.class.superclass == Net::HTTPSuccess
      end
    end
  end
end