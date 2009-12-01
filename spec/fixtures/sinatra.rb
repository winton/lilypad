class SinatraApp < Sinatra::Base
  
  use Rack::Lilypad, 'xxx'
  
  get "/raise" do
    raise 'Test'
  end
end