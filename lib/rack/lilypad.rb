require 'builder'
require 'net/http'
require 'rack'
require 'yaml'

module Rack
  class Lilypad
    
    attr_accessor :filters

    def initialize(app, api_key = nil)
      @app = app
      @filters = []
      yield self if block_given?
      @hoptoad = Hoptoad.new(api_key, @filters)
    end

    def call(env)
      status, headers, body =
        begin
          @app.call(env)
        rescue Exception => e
          @hoptoad.post(e, env)
          raise
        end
      @hoptoad.post(env['rack.exception'], env) if env['rack.exception']
      [ status, headers, body ]
    end

    class Hoptoad
      
      def initialize(api_key = nil, filters = [])
        @api_key = api_key
        @filters = filters
      end
      
      def backtrace(exception)
        regex = %r{^([^:]+):(\d+)(?::in `([^']+)')?$}
        exception.backtrace.map do |line|
          _, file, number, method = line.match(regex).to_a
          Backtrace.new(file, number, method)
        end
      end
      
      def filter(hash)
        hash.inject({}) do |acc, (key, val)|
          acc[key] = @filters.any? { |f| key.to_s =~ Regexp.new(f) } ? "[FILTERED]" : val
          acc
        end
      end
      
      def post(exception, env)
        return unless production?
        uri = URI.parse("http://hoptoadapp.com/notices/")
        Net::HTTP.start(uri.host, uri.port) do |http|
          headers = {
            'Content-type' => 'text/xml',
            'Accept' => 'text/xml, application/xml'
          }
          http.read_timeout = 5 # seconds
          http.open_timeout = 2 # seconds
          begin
            http.post uri.path, xml(exception, env), headers
            env['hoptoad.notified'] = true
          rescue TimeoutError => e
          end
        end
      end
      
      def production?
        %w(staging production).include?(ENV['RACK_ENV'])
      end
      
      def xml(exception, env)
        environment = filter(ENV.to_hash.merge(env))
        request = Rack::Request.new(env)
        request_path = request.script_name + request.path_info
        
        xml = ::Builder::XmlMarkup.new
        xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
        xml.notice(:version => '2.0.0') do |n|
          n.tag! 'api-key', @api_key
          n.notifier do |n|
            n.name 'Lilypad'
            n.url 'http://github.com/winton/lilypad'
            n.version '0.1.0'
          end
          n.error do |e|
            e.tag! 'class', exception.class.name
            e.message exception.message
            e.backtrace do |b|
              backtrace(exception).each do |line|
                b.line(:method => line.method, :file => line.file, :number => line.number)
              end
            end
          end
          n.request do |r|
            r.component request_path
            r.url request_path
            if request.params.any?
              r.params do |p|
                request.params.each do |key, value|
                  p.var(value, :key => key)
                end
              end
            end
            if environment.any?
              r.tag!('cgi-data') do |c|
                environment.each do |key, value|
                  c.var(value, :key => key)
                end
              end
            end
          end
          n.tag!('server-environment') do |s|
            s.tag! 'project-root', Dir.pwd
            s.tag! 'environment-name', ENV['RACK_ENV'] || 'development'
          end
        end
        @@last_response = xml.target!
      end
      
      class <<self
        def last_response
          @@last_response
        end
      end

      class Backtrace < Struct.new(:file, :number, :method)
      end
    end
  end
end