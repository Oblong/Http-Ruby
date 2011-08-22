require 'rubygems'
require 'thin'
require 'connection'
require 'tcp_server'
require 'rack'
require 'http'

class MyClass
  def initialize; end
  def call(env, request, response)
    response.write("hello world")
    response.write("hello world this is fantastic")
    response.doEnd
  end
end

app = Rack::Builder.app do
  use Rack::ShowExceptions
  map "/" do
    use HTTP::FromRack
    run MyClass.new
  end
end

Thin::Server.start('0.0.0.0', 3000, app)
