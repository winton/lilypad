$testing = true
SPEC = File.dirname(__FILE__)
$:.unshift File.expand_path("#{SPEC}/../lib")

require 'lilypad'
require 'pp'

require 'rubygems'
require 'nokogiri'
require 'rack/test'
require 'sinatra/base'

# Depend on rack/lilypad/rails to set ENV['RACK_ENV'] from this
ENV['RAILS_ENV'] = 'production'

require File.expand_path("#{SPEC}/fixtures/test_exception_middleware")
require File.expand_path("#{SPEC}/fixtures/rails/config/environment")
require File.expand_path("#{SPEC}/fixtures/sinatra")

Spec::Runner.configure do |config|
end

# For use with rspec textmate bundle
def debug(object)
  puts "<pre>"
  puts object.pretty_inspect.gsub('<', '&lt;').gsub('>', '&gt;')
  puts "</pre>"
end

def stub_net_http
  @http = mock(:http)
  @http.stub!(:read_timeout=)
  @http.stub!(:open_timeout=)
  @http.stub!(:post).and_return Net::HTTPOK.new(nil, nil, nil)
  Net::HTTP.stub!(:start).and_yield(@http)
end

def validate_xml
  xsd = Nokogiri::XML::Schema(File.read(SPEC + '/fixtures/hoptoad_2_0.xsd'))
  doc = Nokogiri::XML(Lilypad::Hoptoad::XML.last_request)
  
  errors = xsd.validate(doc)
  errors.each do |error|
    puts error.message
  end
  errors.length.should == 0
end

class TestError < RuntimeError
end
