require 'rubygems'
gem 'require'
require 'require'

Require File.dirname(__FILE__) do
  gem(:builder, '>=2.1.2') { require 'builder' }
  gem(:nokogiri) { require 'nokogiri' }
  gem(:rack) { require 'rack' }
  gem(:'rack-test') { require 'rack/test' }
  gem :rails, '=2.3.5'
  gem(:rake, '=0.8.7') { require 'rake' }
  gem :require, '=0.1.8'
  gem :rspec, '=1.3.0'
  gem(:sinatra) { require 'sinatra/base' }
  
  gemspec do
    author 'Winton Welsh'
    dependencies do
      gem :builder
      gem :require
    end
    email 'mail@wintoni.us'
    name 'lilypad'
    homepage "http://github.com/winton/#{name}"
    summary "Hoptoad notifier for rack-based frameworks"
    version '0.3.0'
  end
  
  lib do
    gem :builder
    gem :rack
    require 'net/http'
    require "lib/lilypad/config"
    require "lib/lilypad/config/request"
    require "lib/lilypad/log"
    require "lib/lilypad/limit"
    require "lib/lilypad/hoptoad/deploy"
    require "lib/lilypad/hoptoad/notify"
    require "lib/lilypad/hoptoad/xml"
    require "lib/rack/lilypad"
  end
  
  rakefile do
    gem(:rake) { require 'rake/gempackagetask' }
    gem(:rspec) { require 'spec/rake/spectask' }
    require 'require/tasks'
  end
  
  spec_helper do
    gem :rails
    gem :sinatra
    gem :nokogiri
    gem :'rack-test'
    require 'require/spec_helper'
    require 'lib/lilypad'
    require 'pp'
    require "spec/fixtures/test_exception_middleware"
    require "spec/fixtures/rails/config/environment"
    require "spec/fixtures/sinatra"
  end
end