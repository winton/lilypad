class Lilypad
  class Log
    
    def initialize(type, response)
      @response = response
      @type = type
      self.class.log title, xml_request, response_body
    end
    
    class <<self

      def log(*lines)
        ::File.open Config.log, 'a' do |f|
          f.write lines.compact.join("\n\n") + "\n\n"
        end
      end
    end
    
    module Methods
      
      def log(type, response)
        if Config.log
          Log.new type, response
        end
      end
    end
    
    private
    
    def response_body
      @response.body rescue nil
    end
    
    def success?
      @response.class.superclass == Net::HTTPSuccess
    end
    
    def title
      "#{@type.to_s.capitalize} #{success? ? 'Success' : 'Failure'}:"
    end
    
    def xml_request
      Hoptoad::XML.last_request
    end
  end
end