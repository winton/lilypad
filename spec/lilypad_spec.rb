require "#{File.dirname(__FILE__)}/spec_helper"

describe Rack::Lilypad do

  include Rack::Test::Methods
  
  before(:each) do
    @app = lambda { |env| raise TestError, 'Test' }
    @env = Rack::MockRequest.env_for("/test")
    stub_net_http
  end
  
  it "should yield a configuration object to the block when created" do
    Rack::Lilypad.new(@app, '') do
      filters %w(T1 T2)
      log 'T3'
    end
    Lilypad::Config.filters.include?('T1').should == true
    Lilypad::Config.filters.include?('T2').should == true
    Lilypad::Config.log.should == 'T3'
    
    Lilypad::Config.filters []
    Lilypad::Config.log false
  end
  
  it "should write to a log file on success and failure" do
    log_path = "#{SPEC}/fixtures/hoptoad.log"
    notifier = Rack::Lilypad.new(@app, '') do |app|
      log log_path
    end
    
    notifier.call(@env) rescue nil
    
    File.exists?(log_path).should == true
    File.read(log_path).should =~ /Notify Success/
    File.delete(log_path)
    
    @http.stub!(:post).and_return false
    notifier.call(@env) rescue nil
    
    File.exists?(log_path).should == true
    File.read(log_path).should =~ /Notify Failure/
    File.delete(log_path)
    
    Lilypad::Config.log false
  end
  
  it "should transfer valid XML to Hoptoad" do
    # Test complex environment variables
    @env['rack.hash_test'] = { :test => true }
    @env['rack.object_test'] = Object.new
    
    notifier = Rack::Lilypad.new(@app, '')
    notifier.call(@env) rescue nil
    validate_xml
  end
  
  it "should provide a notify method" do
    @http.should_receive(:post)
    begin
      raise TestError, 'Test'
    rescue Exception => e
      Lilypad.notify(e)
    end
  end
  
  it "should provide a deploy method" do
    Net::HTTP.should_receive(:post_form)
    Lilypad.deploy(
      :username => 't1',
      :environment => 't2',
      :revision => 't3',
      :repository => 't4'
    )
  end
  
  it "should provide a limit method" do
    Lilypad::Limit.should_receive(:limit)
    Lilypad.limit(@env)
  end
end