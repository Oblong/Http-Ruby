class MyTest
  def initialize; end
  def call(env, request, response)
    response.writeHead 'key' => 'value'
    response.write Time.now.to_s
    sleep 2
    response.write Time.now.to_s
    response.doEnd
  end
end
