class MyTest
  def initialize; end
  def call(env, request, response)
    4.times do 
      sleep 0.25
      response.write Time.now.to_s
    end

    response.doEnd
  end
end
