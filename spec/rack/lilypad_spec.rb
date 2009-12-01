require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Rack::Lilypad do

  include Rack::Test::Methods

  def app
    SinatraApp.new
  end
  
  it "should do something" do
    get "/raise"
  end
end