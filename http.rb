#
# Implemented based on documentation from http://nodejs.org/docs/v0.5.0/api/http.html
# Quotations are used wherein relevant
#
module HTTP
  attr_reader :agent
  include EventEmitter

  def self.createServer(&requestListener)
  end


  class FromRack
    def initialize
      @threadMap = {}
    end

    def each
      @threadMap['response.body'] = Thread.new {
         yield @response.body.pop 
      }.join
    end

    def call env
      httpHeaders = env.reject{ | key, value | key.class != String || key[0..3] != 'HTTP' }
      pairwise = {}

      httpHeaders.each { | key, value | 
        string = key.downcase.gsub('_', ' ')[5..-1].split(' ').map { | x | x.capitalize }
        string = string.join('-')

        pairwise[ string ] = value 
      }

      @request = ServerRequest.new({
        'method' => env['REQUEST_METHOD'],
        'url' => env['REQUEST_URI'],
        'headers' => pairwise,
        'threadMap' => @threadMap
      })

      @threadMap['request.data'] = Thread.new {
        env['rack.input'].each do | data |
          @request.emit('data', data)
        end

        @request.emit('end')
      }

      @response = ServerResponse.new 'threadMap' => @threadMap 

      # if we block on the header writing code and then
      # yield when it exits, we can achieve the documented
      # results
      @threadMap['response.header'] = Thread.new {
        loop {
          sleep 0.1
        }
      }.join

      # If the above thread is run, then we can return with
      # the headers + the yield for the call
      statusCode, headers = @response.headerFull

      [ statusCode,
        headers,
        self
      ]
    end
  end

  class Server
    def initialize
    end

    def close
      raise NotImplementedError
    end 
  end

  class ServerRequest
    attr_reader :method, :url, :headers, :trailers, :httpVersion, :connection

    def initialize(options = {})
      @trailers = nil
      @connection = nil
      @encoding = nil

      options.each { | key, value |
        instance_variable_set("@#{key}", value)
      }
    end

    def setEncoding(encoding = nil)
      @encoding = encoding
    end

    def pause
      @threadMap['request.data'].stop if @threadMap['request.data'].status == 'run'
    end

    def resume
      @threadMap['request.data'].run if @threadMap['request.data'].status == 'sleep'
    end
  end

  class ServerResponse
    attr_reader :statusCode, :headerFull, :body

    def initialize(options = {})
      @headerFull = ''
      @headerMap = {
        'Content-Type' => 'text/plain'
      }
      @statusCode = 200
      @body = Queue.new

      options.each { | key, value |
        instance_variable_set("@#{key}", value)
      }
    end

    def writeContinue
      raise NotImplementedError
    end

    # This doesn't hit the wire until the total response
    #
    #   "The last argument, headers, are the response headers. 
    #    Optionally one can give a human-readable reasonPhrase 
    #    as the second argument."
    #
    def writeHead(*args) #statusCode, reasonPhrase = nil, headers = nil )
      # First take the end
      headers = args.pop

      # And the beginning
      @statusCode = args.shift

      # If there is anything left, use that
      reasonPhrase = args[0] if args.length

      @headerFull = [ @statusCode, headers ]

      @threadMap['response.header'].kill
    end

    def setHeader(name, value)
      @headerMap[name] = value
    end

    def getHeader(name)
      @headerMap[name]
    end

    def removeHeader(name)
      @headerMap.delete name if @headerMap.has_key? name
    end

    def write(chunk, encoding = 'utf8')
      #  "If this method is called and 
      #   response.writeHead() has not been 
      #   called, it will switch to implicit 
      #   header mode and flush the implicit 
      #   headers."
      @threadMap['response.header'].kill if @threadMap['response.header'].status == 'run'

      @body << chunk
    end

    def addTrailers(headers = {})
      raise NotImplementedError
    end

    def doEnd(data = nil, encoding = nil)
      #  "If data is specified, it is equivalent to 
      #   calling response.write(data, encoding) 
      #   followed by response.end()."
      write(data, encoding) unless data.nil?

      @threadMap['response.body'].kill
    end
  end

  def self.request(options = {}, &callback)
    raise NotImplementedError
  end

  def self.get(options = {}, &callback)
    raise NotImplementedError
  end

  def self.getAgent(options = {})
    raise NotImplementedError
  end

  class ClientRequest
    def initialize; end

    def write(chunk, encoding = 'utf8')
      raise NotImplementedError
    end

    def doEnd(data = nil, encoding = nil)
      #  "If data is specified, it is equivalent to 
      #   calling request.write(data, encoding) 
      #   followed by request.end()."
      write(data, encoding) unless data.nil?
      raise NotImplementedError
    end

    def abort
      raise NotImplementedError
    end
  end

  class ClientResponse
    attr_accessor :statusCode, :httpVersion, :headers, :trailers

    #  "Also response.httpVersionMajor is the 
    #   first integer and response.httpVersionMinor 
    #   is the second."
    attr_reader :httpVersionMajor, :httpVersionMinor

    def initialize

      # Note: we are just using 1.1 for now.
      @httpVersionMinor = 1
      @httpVersionMajor = 1

      @httpVersion = "#{@httpVersionMajor}.#{@httpVersionMinor}"
    end

    def setEncoding(encoding = nil)
      @encoding = encoding
    end

    def pause
      raise NotImplementedError
    end

    def resume
      raise NotImplementedError
    end
  end
end
