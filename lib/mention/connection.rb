module Mention
  class Connection

    def initialize(account_id, token)
      @account_id = account_id
      @token      = token
      @uri        = URI.parse("https://api.mention.net/api/accounts/#{account_id}")
      @http       = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = true
    end

    def get(path = '', params = {})
      url = params.empty? ? path : "#{path}?#{encode(params)}"
      request :get, uri.path + url, headers
    end

    def post(path, params, custom_headers = {})
      request :post, uri.path + path, params, headers.merge(custom_headers)
    end

    # proof of concept
    def put(path, params, custom_headers = {})
      response = http.send_request('PUT', uri.path + path, params, headers.merge(custom_headers))
      unpack(response)
    end

    def delete(path)
      request :delete, uri.path + path, headers
    end

    private
      attr_reader :token, :account_id, :http, :uri

      def request(method, *args)
        response = http.send(method, *args)
        unpack(response)
      end

     def unpack(response)
       case response["Content-Encoding"]
       when "gzip", "x-gzip"
         gzip = Zlib::GzipReader.new(::StringIO.new(response.body))
         gzip.read
       when "deflate"
         Zlib::Inflate.inflate(response.body)
        else
          response.body
       end
     end

      def headers
         @headers ||= { 'Authorization' => "Bearer #{token}", "Accept" => "application/json", 'Accept-Encoding'=>'gzip, deflate' }
      end

      def encode(params)
        URI.encode_www_form(params)
      end
  end
end
