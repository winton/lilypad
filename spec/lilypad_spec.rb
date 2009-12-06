require "#{File.dirname(__FILE__)}/spec_helper"

describe Rack::Lilypad do

  include Rack::Test::Methods
  
  before(:each) do
    @app = lambda { |env| raise TestError, 'Test' }
    @env = Rack::MockRequest.env_for("/test")
    @http = mock(:http)
    @http.stub!(:read_timeout=)
    @http.stub!(:open_timeout=)
    @http.stub!(:post).and_return Net::HTTPOK.new(nil, nil, nil)
    Net::HTTP.stub!(:start).and_yield(@http)
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
    validate_xml
  end
  
  it "should provide a deploy method" do
    Net::HTTP.should_receive(:post_form).and_return(Net::HTTPOK.new(nil, nil, nil))
    Lilypad.deploy(
      :username => 't1',
      :environment => 't2',
      :revision => 't3',
      :repository => 't4'
    )
  end
  
  describe 'Rails' do
    
    def app
      ActionController::Dispatcher.new
    end
    
    it "should set ENV['RACK_ENV']" do
      ENV['RACK_ENV'].should == 'production'
    end
    
    it "should post an error to Hoptoad" do
      @http.should_receive(:post)
      get "/test" rescue nil
    end
    
    it "should re-raise the exception (with ActionController::Failsafe disabled)" do
      lambda { get "/test" }.should raise_error(TestError)
    end
    
    it "should catch middleware exceptions" do
      @http.should_receive(:post)
      get "/nothing?test_exception=1" rescue nil
    end
    
    it "should not do anything if non-production environment" do
      ENV['RACK_ENV'] = 'development'
      @http.should_not_receive(:post)
      get "/test" rescue nil
    end
  end
  
  describe 'Sinatra' do
    
    def app
      SinatraApp.new
    end
    
    before(:each) do
      ENV['RACK_ENV'] = 'production'
    end
    
    it "should post an error to Hoptoad" do
      @http.should_receive(:post)
      get "/test" rescue nil
    end

    it "should re-raise the exception" do
      lambda { get "/test" }.should raise_error(TestError)
    end
    
    it "should catch middleware exceptions" do
      @http.should_receive(:post)
      get "/nothing?test_exception=1" rescue nil
    end
    
    it "should not do anything if non-production environment" do
      ENV['RACK_ENV'] = 'development'
      @http.should_not_receive(:post)
      get "/test" rescue nil
    end
  end
end