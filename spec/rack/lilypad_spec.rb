require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

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
    notifier = Rack::Lilypad.new(@app, '') do |app|
      app.filters << %w(T1 T2)
      app.log = 'T3'
    end
    notifier.filters.include?('T1').should == true
    notifier.filters.include?('T2').should == true
    notifier.log.should == 'T3'
  end
  
  it "should write to a log file on success and failure" do
    log = "#{SPEC}/fixtures/hoptoad.log"
    notifier = Rack::Lilypad.new(@app, '') do |app|
      app.log = log
    end
    
    notifier.call(@env) rescue nil
    
    File.exists?(log).should == true
    File.read(log).should =~ /Hoptoad Success/
    File.delete(log)
    
    @http.stub!(:post).and_return false
    notifier.call(@env) rescue nil
    
    File.exists?(log).should == true
    File.read(log).should =~ /Hoptoad Failure/
    File.delete(log)
  end
  
  it "should transfer valid XML to Hoptoad" do
    # Test complex environment variables
    @env['rack.hash_test'] = { :test => true }
    @env['rack.object_test'] = Object.new
    
    notifier = Rack::Lilypad.new(@app, '')
    notifier.call(@env) rescue nil
    validate_xml
  end
  
  it "should allow direct access to the post method" do
    @http.should_receive(:post)
    begin
      raise TestError, 'Test'
    rescue Exception => e
      Rack::Lilypad.notify(e)
    end
    validate_xml
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