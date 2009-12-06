class Lilypad
  module Sinatra
    
    def self.included(base)
      base.set(:raise_errors, true) if Lilypad.production?
    end
  end
end

Sinatra::Base.send(:include, Lilypad::Sinatra)
Sinatra::Application.send(:include, Lilypad::Sinatra)