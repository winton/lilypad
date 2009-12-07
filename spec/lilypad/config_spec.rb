require File.expand_path("#{File.dirname __FILE__}/../spec_helper")

describe Lilypad::Config do

  before(:each) do
    Lilypad::Config.api_key 'api_key'
    Lilypad::Config.deploy_url 'deploy_url'
    Lilypad::Config.environments 'environments'
    Lilypad::Config.filters 'filters'
    Lilypad::Config.log 'log'
    Lilypad::Config.notify_url 'notify_url'
  end

  after(:each) do
    Lilypad::Config.class_eval do
      @api_key = nil
      @deploy_url = nil
      @environments = nil
      @filters = nil
      @log = nil
      @notify_url = nil
    end
  end

  it "should set options" do
    Lilypad::Config.api_key.should == 'api_key'
    Lilypad::Config.deploy_url.should == 'deploy_url'
    Lilypad::Config.environments.should == 'environments'
    Lilypad::Config.filters.should == 'filters'
    Lilypad::Config.log.should == 'log'
    Lilypad::Config.notify_url.should == 'notify_url'
  end
  
  it "should require the rails adapter when the rails method is called" do
    adapter = File.expand_path "#{SPEC}/../lib/lilypad/adapters/rails"
    Lilypad::Config.should_receive(:require).with(adapter)
    Lilypad::Config.rails
  end
  
  it "should require the rails adapter when the sinatra method is called" do
    adapter = File.expand_path "#{SPEC}/../lib/lilypad/adapters/sinatra"
    Lilypad::Config.should_receive(:require).with(adapter)
    Lilypad::Config.sinatra
  end
  
  describe :Methods do
    
    include Lilypad::Config::Methods
    
    it "should provide an api_key method" do
      Lilypad::Config.api_key 'api_key'
      api_key.should == 'api_key'
      Lilypad::Config.api_key { |env, e| [ env, e ].join '_' }
      api_key.should == 'api_key' # api string takes precedence even when block configured
      Lilypad::Config.class_eval { @api_key = nil }
      api_key('api_key', 'block').should == 'api_key_block' # string is nil, now use the block
    end
  end
end