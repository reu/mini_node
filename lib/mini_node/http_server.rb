require "socket"

require "http/parser"

require "mini_node/event_emitter"
require "mini_node/stream"
require "mini_node/file"
require "mini_node/server"

module MiniNode
  class HttpServer
    include EventEmitter

    CRLF = "\r\n"

    class Request
      attr_accessor :verb
      attr_accessor :path
      attr_accessor :headers
      attr_accessor :body

      %w(get post put patch delete head options).each do |verb|
        define_method(verb + "?") do
          self.verb.to_s.downcase == verb
        end
      end
    end

    class Response
      STATUS_MESSAGES = {
        200 => "OK",
        201 => "Created",
        202 => "Accepted",
        203 => "Non-Authoritative Information",
        204 => "No Content",
        205 => "Reset Content",
        206 => "Partial Content",
        300 => "Multiple Choices",
        301 => "Moved Permanently",
        302 => "Found",
        303 => "See Other",
        304 => "Not Modified",
        305 => "Use Proxy",
        306 => "Switch Proxy",
        307 => "Temporary Redirect",
        308 => "Permanent Redirect",
        400 => "Bad Request",
        401 => "Unauthorized",
        402 => "Payment Required",
        403 => "Forbidden",
        404 => "Not Found",
        405 => "Method Not Allowed",
        406 => "Not Acceptable",
        407 => "Proxy Authentication Required",
        408 => "Request Timeout",
        409 => "Conflict",
        410 => "Gone",
        411 => "Length Required",
        412 => "Precondition Failed",
        413 => "Request Entity Too Large",
        414 => "Request-URI Too Long",
        415 => "Unsupported Media Type",
        416 => "Requested Range Not Satisfiable",
        417 => "Expectation Failed",
        418 => "I'm a teapot",
        426 => "Upgrade Required",
        428 => "Precondition Required",
        429 => "Too Many Requests",
        431 => "Request Header Fields Too Large",
        500 => "Internal Server Error",
        501 => "Not Implemented",
        502 => "Bad Gateway",
        503 => "Service Unavailable",
        504 => "Gateway Timeout",
        505 => "HTTP Version Not Supported",
        506 => "Variant Also Negotiates",
        510 => "Not Extended",
        511 => "Network Authentication Required"
      }

      def initialize(client)
        @client = client
      end

      def write_head(status, headers = {})
        @client.write("HTTP/1.1 #{status} #{STATUS_MESSAGES[status]}" + CRLF)

        default_headers.merge(headers).each do |name, value|
          @client.write("#{name}: #{value}" + CRLF)
        end
        @client.write(CRLF)

        self
      end

      def write(data)
        @client.write(data)
        self
      end

      def close
        @client.close
      end

      private

      def default_headers
        {
          "Connection": "close",
          "Date": Time.now.gmtime.strftime("%a, %e %b %Y %H:%M:%S %Z")
        }
      end
    end

    def initialize(server)
      server.on(:accept) do |client|
        parser = Http::Parser.new

        request = Request.new
        request.body = ""

        parser.on_headers_complete = proc do
          request.verb = parser.http_method
          request.path = parser.request_url
          request.headers = parser.headers
        end

        parser.on_body = proc do |chunk|
          request.body << chunk
        end

        parser.on_message_complete = proc do |env|
          response = Response.new(client)
          emit(:request, request, response)
        end

        client.on(:data) do |data|
          parser << data
        end
      end
    end
  end
end
