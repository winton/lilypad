require File.expand_path("#{File.dirname __FILE__}/../../spec_helper")

describe Lilypad::Hoptoad::Deploy do
  
  before(:each) do
    stub_net_http
    @options = {
      :username => 'username',
      :environment => 'environment',
      :revision => 'revision',
      :repository => 'repository'
    }
    @instance = Lilypad::Hoptoad::Deploy.new(@options)
  end
  
  describe :initialize do
    
    after(:each) do
      @instance.send(:initialize, @options)
    end
    
    it "should call the post method" do
      @instance.should_receive(:post)
    end
    
    it "should log the event" do
      @instance.should_receive(:log).with(:deploy, @http_ok)
    end
    
    it "should return the success status" do
      @instance.should_receive(:success?)
    end
  end
  
  describe :params do
    
    before(:each) do
      Lilypad { api_key '' }
    end
    
    it "should return parameters for the Hoptoad request" do
      @instance.send(:params).should == {
        'api_key' => '',
        'deploy[local_username]' => @options[:username],
        'deploy[rails_env]' => @options[:environment],
        'deploy[scm_revision]' => @options[:revision],
        'deploy[scm_repository]' => @options[:repository]
      }
    end
  end
  
  describe :post do
    
    before(:each) do
      URI.stub!(:parse).and_return('uri')
      @instance.stub!(:params).and_return('params')
    end
    
    after(:each) do
      @instance.send(:post)
    end
    
    it "should parse the URI" do
      URI.should_receive(:parse).with(Lilypad::Config.deploy_url)
    end
    
    it "should post the form using the URI and params method" do
      @instance.should_receive(:params)
      Net::HTTP.should_receive(:post_form).with('uri', 'params')
    end
  end
  
  describe :success? do
    
    it "should make sure the response's superclass equals Net::HTTPSuccess" do
      Net::HTTP.stub!(:post_form).and_return(nil)
      @instance.send(:initialize, @options)
      @instance.send(:success?).should == false
      
      Net::HTTP.stub!(:post_form).and_return(@http_ok)
      @instance.send(:initialize, @options)
      @instance.send(:success?).should == true
    end
  end
end