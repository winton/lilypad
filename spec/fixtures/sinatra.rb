class SinatraApp < Sinatra::Base
  
  use Rack::Lilypad, 'xxx'
  
  get "/pulse" do
    raise TestError, 'Test'
  end
end