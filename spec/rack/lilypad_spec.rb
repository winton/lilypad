require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Rack::Lilypad do

  include Rack::Test::Methods

  def app
    SinatraApp.new
  end
  
  before(:each) do
    ENV['RACK_ENV'] = 'production'
    @app = lambda { |env| raise TestError, 'Test' }
    @env = Rack::MockRequest.env_for("/raise")
    @http = mock(:http)
    @http.stub!(:read_timeout=)
    @http.stub!(:open_timeout=)
    @http.stub!(:post).and_return Net::HTTPSuccess
    Net::HTTP.stub!(:start).and_yield(@http)
  end
  
  it "should yield a configuration object to the block when created" do
    notifier = Rack::Lilypad.new(@app, '') do |app|
      app.filters << %w(T1 T2)
    end
    notifier.filters.should include('T1')
    notifier.filters.should include('T2')
  end
  
  it "should write to a log if specified" do
    path = "#{SPEC}/fixtures/hoptoad.log"
    notifier = Rack::Lilypad.new(@app, '') do |app|
      app.log = path
    end
    notifier.call(@env) rescue nil
    File.exists?(path).should == true
    File.delete path
    File.exists?(path).should == false
  end
  
  it "should post an error to Hoptoad" do
    @http.should_receive(:post)
    get "/raise" rescue nil
  end
  
  it "should re-raise the exception" do
    lambda { get "/raise" }.should raise_error(TestError)
  end
  
  it "should transfer valid XML to Hoptoad" do
    get "/raise" rescue nil
    
    xsd = Nokogiri::XML::Schema(File.read(SPEC + '/fixtures/hoptoad_2_0.xsd'))
    doc = Nokogiri::XML(Rack::Lilypad::Hoptoad.last_response)
    
    errors = xsd.validate(doc)
    errors.each do |error|
      puts error.message
    end
    errors.length.should == 0
  end
end