class TestExceptionMiddleware
  def initialize(app, session_key = '_session_id')
    @app = app
    @session_key = session_key
  end

  def call(env)
    req = Rack::Request.new(env)
    if req.params['test_exception']
      raise "raising a RuntimeError to test the middleware exception"
    else
      @app.call(env)
    end
  end
end
