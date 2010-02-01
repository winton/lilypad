require File.expand_path("#{File.dirname __FILE__}/../spec_helper")

describe Lilypad::Config do

  before(:each) do
    @env = { 'PATH_INFO' => '/test', 'REQUEST_METHOD' => 'GET' }
    Lilypad::Limit.reset
  end
  
  describe :limit do
    
    it "should do nothing if the environment isn't complete" do
      Lilypad::Limit.limit({})
      Lilypad::Limit.errors.should == {}
    end
    
    it "should add an entry to @@errors" do
      Lilypad::Limit.limit(@env)
      Lilypad::Limit.errors.should == {"GET /test" => 1}
    end
    
    it "should increment @@errors" do
      Lilypad::Limit.limit(@env)
      Lilypad::Limit.limit(@env)
      Lilypad::Limit.errors.should == {"GET /test" => 2}
    end
    
    it "should add an entry to @@expire" do
      Lilypad::Limit.limit(@env)
      Lilypad::Limit.expire["GET /test"].to_s.should == (Time.now.utc + 10*60).to_s
    end
  end
  
  describe :limit? do
    
    before(:each) do
      Lilypad.stub!(:notify)
    end
    
    it "should return false if the environment isn't complete" do
      Lilypad::Limit.limit?({}).should == false
    end
    
    it "should return true and call notify if error limit reached" do
      101.times do
        Lilypad::Limit.limit(@env)
      end
      Lilypad.should_receive(:notify)
      Lilypad::Limit.limit?(@env).should == true
    end
    
    it "should return false and not call notify if error limit not reached" do
      100.times do
        Lilypad::Limit.limit(@env)
      end
      Lilypad.should_not_receive(:notify)
      Lilypad::Limit.limit?(@env).should == false
    end
  end
  
  describe :unlimit do
    
    it "should do nothing if the environment isn't complete" do
      Lilypad::Limit.unlimit({})
      Lilypad::Limit.errors.should == {}
    end
    
    it "should reset the count" do
      Lilypad::Limit.unlimit(@env)
      Lilypad::Limit.errors.should == {"GET /test" => 0}
    end
  end
end