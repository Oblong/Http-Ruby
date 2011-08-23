class MyTest
  def initialize; end
  def call(env, request, response)
    response.write Time.now.to_s
    response.doEnd
  end
end
