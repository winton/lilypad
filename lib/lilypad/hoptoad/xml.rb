class Lilypad
  class Hoptoad
    class XML
      class <<self
        
        include Config::Methods
        
        def build(backtrace, env, exception, request, request_path)
          @@last_request = nil
          xml = ::Builder::XmlMarkup.new
          xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
          xml.notice :version => '2.0.0' do |n|
            n.tag! 'api-key', api_key
            n.notifier do |n|
              n.name 'Lilypad'
              n.url 'http://github.com/winton/lilypad'
              n.version '0.2.4'
            end
            n.error do |e|
              e.tag! 'class', exception.class.name
              e.message exception.message
              e.backtrace do |b|
                backtrace.each do |line|
                  b.line :method => line.method, :file => line.file, :number => line.number
                end
              end
            end
            n.request do |r|
              r.action Config::Request.action
              r.component Config::Request.component || request_path
              r.url request_path
              if request && request.params.any?
                r.params do |p|
                  request.params.each do |key, value|
                    p.var value.to_s, :key => key
                  end
                end
              end
              if env.any?
                r.tag! 'cgi-data' do |c|
                  env.each do |key, value|
                    c.var value.to_s, :key => key
                  end
                end
              end
            end
            n.tag! 'server-environment' do |s|
              s.tag! 'project-root', Dir.pwd
              s.tag! 'environment-name', ENV['RACK_ENV'] || 'development'
            end
          end
          @@last_request = xml.target!
        end
        
        def last_request
          @@last_request
        end
      end
    end
  end
end