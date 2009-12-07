require File.expand_path("#{File.dirname __FILE__}/../../spec_helper")

describe Lilypad::Config::Request do

  before(:each) do
    Lilypad::Config::Request.action 'action'
    Lilypad::Config::Request.component 'component'
  end

  after(:each) do
    Lilypad::Config::Request.class_eval do
      @action = nil
      @component = nil
    end
  end

  it "should set options" do
    Lilypad::Config::Request.action.should == 'action'
    Lilypad::Config::Request.component.should == 'component'
  end

  it "should provide a method to reset all options" do
    Lilypad::Config::Request.reset!
    Lilypad::Config::Request.action.should == nil
    Lilypad::Config::Request.component.should == nil
  end
end