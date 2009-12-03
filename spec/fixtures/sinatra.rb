class SinatraApp < Sinatra::Base
  
  use Rack::Lilypad, 'xxx'
  use TestExceptionMiddleware
  
  get "/nothing" do
    nil
  end
  
  get "/test" do
    raise TestError, 'Test'
  end
end