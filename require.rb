require 'rubygems'
gem 'require'
require 'require'

Require File.dirname(__FILE__) do
  gem(:builder, '>=2.1.2') { require 'builder' }
  gem :require, '=0.1.6'
  gem(:rake, '=0.8.7') { require 'rake' }
  gem :rspec, '=1.3.0'
  
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
    version '0.3.1'
  end
  
  lib do
    gem :builder
    require 'net/http'
    require 'rack'
    require "lib/lilypad/config"
    require "lib/lilypad/config/request"
    require "lib/lilypad/log"
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
    require 'require/spec_helper'
    require 'lib/lilypad'
    require 'pp'
    require 'nokogiri'
    require 'rack/test'
    require 'sinatra/base'
    require "spec/fixtures/test_exception_middleware"
    require "spec/fixtures/rails/config/environment"
    require "spec/fixtures/sinatra"
  end
end