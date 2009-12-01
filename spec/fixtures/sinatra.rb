class SinatraApp < Sinatra::Base
  
  use Rack::Lilypad, 'xxx'
  
  get "/raise" do
    raise TestError, 'Test'
  end
end