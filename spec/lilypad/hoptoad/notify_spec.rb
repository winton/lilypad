require File.expand_path("#{File.dirname __FILE__}/../../spec_helper")

describe Lilypad::Hoptoad::Notify do
  
  before(:each) do
    uri = mock(:uri)
    uri.stub!(:host)
    uri.stub!(:port)
    uri.stub!(:path).and_return('uri')
    URI.stub!(:parse).and_return(uri)
    stub_net_http
    begin; raise 'Test'; rescue Exception => e; @e = e; end
    @instance = Lilypad::Hoptoad::Notify.new(nil, @e)
  end
  
  describe :initialize do
    
    before(:each) do
      Lilypad::Hoptoad::XML.stub!(:build).and_return('xml')
      @instance.stub!(:headers).and_return 'headers'
      @instance.stub!(:parse).and_return ['parse']
    end
    
    after(:each) do
      @instance.send(:initialize, nil, @e)
    end
    
    it "should build XML from parse method" do
      Lilypad::Hoptoad::XML.should_receive(:build).with('parse')
    end
    
    it "should post the XML" do
      @http.should_receive(:post).with('uri', 'xml', 'headers')
    end
    
    it "should log the event" do
      @instance.should_receive(:log).with(:notify, @http_ok)
    end
    
    it "should reset the request config" do
      Lilypad::Config::Request.should_receive(:reset!)
    end
    
    it "should return the success status" do
      @instance.should_receive(:success?)
    end
  end
  
  describe :backtrace do
    
    it "should return an array of backtrace information" do
      backtrace = @instance.send(:backtrace)
      backtrace.first.file.should =~ /notify_spec/
      backtrace.first.respond_to?(:number).should == true
      backtrace.first.respond_to?(:method).should == true
      backtrace.length.should > 1
    end
  end
  
  describe :filter do
    
    after(:each) do
      Lilypad { filters [] }
    end
    
    it "should remove elements of a hash for keys that match an element Config.filters" do
      Lilypad { filters [ 't1' ] }
      filtered = @instance.send(:filter, { :t1 => 't1', :t2 => 't2' })
      filtered.should == { :t1 => '[FILTERED]', :t2 => 't2' }
    end
  end
  
  describe :http_start do
    
    after(:each) do
      @instance.send(:http_start) {}
    end
    
    it "should get a URI instance for the notify URL" do
      URI.should_receive(:parse).with(Lilypad::Config.notify_url)
    end
    
    it "should call start on Net::HTTP" do
      Net::HTTP.should_receive(:start)
    end
    
    it "should yield to the block" do
      yielded = false
      @instance.send(:http_start) { yielded = true }
      yielded.should == true
    end
  end
  
  describe :parse do
    
    before(:each) do
      @env = mock(:env)
      @env.stub!(:merge).and_return('env')
      ENV.stub!(:to_hash).and_return(@env)
      @instance.stub!(:filter).and_return('env')
      @instance.stub!(:backtrace).and_return('backtrace')
    end
    
    it "should filter the environment" do
      @instance.should_receive(:filter).with('env')
      ENV.should_receive(:to_hash)
      @env.should_receive(:merge)
      @instance.send(:parse)
    end
    
    it "should return the correct parameters without an environment" do
      @instance.send(:parse).should == [ "backtrace", "env", @e, {}, "Internal" ]
    end
    
    it "should return the correct parameters with an environment" do
      request = mock(:request)
      request.stub!(:params)
      request.stub!(:script_name).and_return 'request_'
      request.stub!(:path_info).and_return 'path'
      Rack::Request.stub!(:new).and_return(request)
      @instance.send(:initialize, {}, @e)
      @instance.send(:parse).should == ["backtrace", "env", @e, "env", "request_path"]
    end
  end
  
  describe :success? do
    
    it "should make sure the response's superclass equals Net::HTTPSuccess" do
      @http.stub!(:post).and_return(nil)
      @instance.send(:initialize, nil, @e)
      @instance.send(:success?).should == false
      
      @http.stub!(:post).and_return(@http_ok)
      @instance.send(:initialize, nil, @e)
      @instance.send(:success?).should == true
    end
  end
end