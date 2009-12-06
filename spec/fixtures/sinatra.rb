Sinatra::Base.set :raise_errors, false

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