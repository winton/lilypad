$testing = true
SPEC = File.dirname(__FILE__)
$:.unshift File.expand_path("#{SPEC}/../lib")

require 'rack/lilypad'
require 'pp'

require 'rubygems'
require 'nokogiri'
require 'rack/test'
require 'sinatra/base'

require File.expand_path("#{SPEC}/fixtures/sinatra")

Spec::Runner.configure do |config|
end

# For use with rspec textmate bundle
def debug(object)
  puts "<pre>"
  puts object.pretty_inspect.gsub('<', '&lt;').gsub('>', '&gt;')
  puts "</pre>"
end
