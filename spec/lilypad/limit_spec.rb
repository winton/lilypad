require File.expand_path("#{File.dirname __FILE__}/../spec_helper")

describe Lilypad::Limit do

  before(:each) do
    @e = TestError.new
    @env = { 'PATH_INFO' => '/test', 'REQUEST_METHOD' => 'GET' }
    Lilypad::Limit.reset
    Lilypad.stub!(:notify)
    Lilypad::Config.limit 3
  end
  
  after(:each) do
    Lilypad::Limit.reset
    Lilypad::Config.limit 100
  end
  
  describe :limit do
    
    it "should do nothing if the environment isn't complete" do
      Lilypad::Limit.limit(@e, {})
      Lilypad::Limit.errors.should == {}
    end
    
    it "should add an entry to @@errors" do
      Lilypad::Limit.limit(@e, @env)
      Lilypad::Limit.errors.should == {"GET /test" => 1}
    end
    
    it "should increment @@errors" do
      2.times do
        Lilypad::Limit.limit(@e, @env)
      end
      Lilypad::Limit.errors.should == {"GET /test" => 2}
    end
    
    it "should update @@errors when the limit is reached" do
      3.times do
        Lilypad::Limit.limit(@e, @env)
      end
      Lilypad::Limit.errors["GET /test"].to_s.should == (Time.now.utc + 60).to_s
    end
    
    it "should set env['lilypad'] when the limit is reached" do
      3.times do
        Lilypad::Limit.limit(@e, @env)
      end
      @env['lilypad'].should == 'Error limit reached'
    end
    
    it "should update @@errors when time limit passes" do
      Lilypad::Limit.errors["GET /test"] = Time.now.utc - 1
      Lilypad::Limit.limit(@e, @env)
      Lilypad::Limit.errors["GET /test"].to_s.should == (Time.now.utc + 60).to_s
    end
  end
  
  describe :limit? do
    
    before(:each) do
      Lilypad.stub!(:notify)
    end
    
    it "should return false if the environment isn't complete" do
      Lilypad::Limit.limit?({}).should == false
    end
    
    it "should return true and set env['lilypad'] if expiration is greater than the current time" do
      Lilypad::Limit.errors["GET /test"] = Time.now.utc + 1
      Lilypad::Limit.limit?(@env).should == true
      @env['lilypad'].should == 'Error limit reached'
    end
    
    it "should return false if expiration is less than the current time" do
      Lilypad::Limit.errors["GET /test"] = Time.now.utc - 1
      Lilypad::Limit.limit?(@env).should == false
    end
  end
end