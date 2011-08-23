server = HTTP::server

server.on('request') { |request, response| 
  response.write "hello world" 
  response.doEnd
}
