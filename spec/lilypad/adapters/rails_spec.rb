require File.expand_path("#{File.dirname __FILE__}/../../spec_helper")

describe Lilypad::Rails do

  include Rack::Test::Methods
  
  def app
    ActionController::Dispatcher.new
  end
  
  describe :post do
  
    after(:each) do
      ENV['RACK_ENV'] = 'production'
    end
    
    before(:each) do
      stub_net_http
    end
  
    it "should post an error to Hoptoad" do
      @http.should_receive(:post)
      get "/test" rescue nil
    end
  
    it "should post middleware exceptions" do
      @http.should_receive(:post)
      get "/nothing?test_exception=1" rescue nil
    end
  
    it "should not post anything if non-production environment" do
      ENV['RACK_ENV'] = 'development'
      @http.should_not_receive(:post)
      get "/test" rescue nil
    end
  end
  
  describe :RACK_ENV do
    
    before(:each) do
      ENV['RACK_ENV'] = nil
      ENV['RAILS_ENV'] = 'production'
      ActionController::Base.send :include, Lilypad::Rails
    end
    
    it "should set ENV['RACK_ENV']" do
      ENV['RACK_ENV'].should == 'production'
    end
  end
  
  describe :rescue_action_without_handler do
    
    it "should set Config::Request.action" do
      Lilypad::Config::Request.should_receive(:action).with('test')
      get "/test" rescue nil
    end
    
    it "should set Config::Request.component" do
      Lilypad::Config::Request.should_receive(:component).with('application')
      get "/test" rescue nil
    end
    
    it "should re-raise the exception (ActionController::Failsafe disabled)" do
      lambda { get "/test" }.should raise_error(TestError)
    end
  end
  
  describe :limit do
    
    before(:each) do
      @env = { 'PATH_INFO' => '/test', 'REQUEST_METHOD' => 'GET' }
      Lilypad::Limit.reset
    end
    
    after(:each) do
      Lilypad::Limit.reset
    end
    
    it "should add an entry to @@errors" do
      get "/test" rescue nil
      Lilypad::Limit.errors.should == {"GET /test" => 1}
    end
    
    it "should raise an error until the limit has been reached" do
      100.times do
        Lilypad::Limit.limit(@env)
      end
      lambda { get "/test" }.should raise_error(TestError)
    end
    
    it "should not raise an error once the limit has been reached" do
      101.times do
        Lilypad::Limit.limit(@env)
      end
      lambda { get "/test" }.should_not raise_error(TestError)
      last_response.body.should == ''
    end
  end
end