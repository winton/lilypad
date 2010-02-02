require File.expand_path("#{File.dirname __FILE__}/../../spec_helper")

describe Lilypad::Sinatra do
  
  include Rack::Test::Methods
  
  def app
    SinatraApp.new
  end
  
  describe :post do
  
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
      ENV['RACK_ENV'] = 'production'
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
end
