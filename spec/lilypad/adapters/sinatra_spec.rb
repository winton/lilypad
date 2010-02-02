require File.expand_path("#{File.dirname __FILE__}/../../spec_helper")

describe Lilypad::Sinatra do
  
  include Rack::Test::Methods
  
  def app
    SinatraApp.new
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
  
  describe :raise_errors do
    
    it "should set raise_errors to true" do
      ::Sinatra::Base.raise_errors?.should == true
    end
    
    it "should re-raise the exception" do
      lambda { get "/test" }.should raise_error(TestError)
    end
  end
  
  describe :limit do
    
    before(:each) do
      @e = TestError.new
      @env = { 'PATH_INFO' => '/test', 'REQUEST_METHOD' => 'GET' }
      Lilypad::Limit.reset
      Lilypad::Config.limit 1
    end
    
    after(:each) do
      Lilypad::Limit.reset
      Lilypad::Config.limit 100
    end
    
    it "should behave as expected" do
      lambda { get "/test" }.should raise_error(TestError)
      
      lambda { get "/test" }.should_not raise_error(TestError)
      last_response.redirect?.should == true
      last_response.location.should == '/500.html'
      
      lambda { get "/test" }.should_not raise_error(TestError)
      last_response.redirect?.should == true
      last_response.location.should == '/500.html'
      
      Lilypad::Limit.errors["GET /test"] = Time.now.utc - 1
      
      lambda { get "/test" }.should raise_error(TestError)
      
      lambda { get "/test" }.should_not raise_error(TestError)
      last_response.redirect?.should == true
      last_response.location.should == '/500.html'
    end
  end
end
