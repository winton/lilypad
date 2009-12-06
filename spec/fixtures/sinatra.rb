Sinatra::Base.class_eval do
  # Make sure the Sinatra adapter does its job
  set :raise_errors, false
end

class SinatraApp < Sinatra::Base
  
  use Rack::Lilypad, '' do
    sinatra
  end
  use TestExceptionMiddleware
  
  get "/nothing" do
    nil
  end
  
  get "/test" do
    raise TestError, 'Test'
  end
end