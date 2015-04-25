module MiniNode
  module HTTP
    class Response
      CRLF = "\r\n"

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

      def initialize(request, client)
        @request = request
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
        @client.close unless @request.keep_alive?
      end

      private

      def default_headers
        {
          "Connection": @request.keep_alive? ? "Keep-Alive" : "close",
          "Date": Time.now.gmtime.strftime("%a, %e %b %Y %H:%M:%S %Z")
        }
      end
    end
  end
end
