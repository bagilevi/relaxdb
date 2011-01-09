module RelaxDB

  class Server
      
    def initialize(host, port, user = nil, pass = nil, ssl = false)
      @host = host
      @port = port
      @user = user
      @pass = pass
      @ssl = ssl
    end

    def delete(uri)
      request(Net::HTTP::Delete.new(uri))
    end

    def get(uri)
      request(Net::HTTP::Get.new(uri))
    end

    def put(uri, json)
      req = Net::HTTP::Put.new(uri)
      req["content-type"] = "application/json"
      req.body = json
      request(req)
    end

    def post(uri, json)
      req = Net::HTTP::Post.new(uri)
      req["content-type"] = "application/json"
      req.body = json
      request(req)
    end

    def request(req)
      req.basic_auth @user, @pass if @user && @pass
      http = Net::HTTP.new(@host, @port)
      http.use_ssl = true if @ssl
      http.start
      res = http.request(req)
      if (not res.kind_of?(Net::HTTPSuccess))
        handle_error(req, res)
      end
      res
    end
  
    def to_s
      "http#{"s" if @ssl}://#{uri_login_prefix}#{@host}:#{@port}/"
    end

    def uri_login_prefix
      if @user
        "#{@user}#{":#{@pass}" if @pass}@"
      end
    end

  
    private

    def handle_error(req, res)
      msg = "#{res.code}:#{res.message}\nMETHOD:#{req.method}\nURI:#{req.path}\n#{res.body}"
      begin
        klass = RelaxDB.const_get("HTTP_#{res.code}")
        e = klass.new(msg)
      rescue
        e = RuntimeError.new(msg)
      end

      raise e
    end
  end
  
end
