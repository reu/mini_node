require "rack"
require "http/parser"

require "pry"

module MiniNode
  module Rack
    class Server
      CRLF = "\r\n".freeze

      def initialize(reactor)
        @reactor = reactor
      end

      def run(app, options)
        server = @reactor.listen(options[:Host], options[:Port])

        server.on(:accept) do |client|
          parser = Http::Parser.new
          request_body = ""

          parser.on_body = proc do |chunk|
            request_body << chunk
          end

          parser.on_message_complete = proc do
            options = {
              :method       => parser.http_method,
              :input        => request_body,
              "REMOTE_ADDR" => client.remote_address
            }.merge(convert_headers(parser.headers))

            normalize_env(options)

            env = ::Rack::MockRequest.env_for(parser.request_url, options)
            status, headers, body = app.call(env)

            headers["Content-Length"] = body[0].bytesize if body.size == 1
            headers["Connection"] = "Close" if headers["Connection"] != "Close"

            response_line = "HTTP/1.1 #{status}#{CRLF}"

            header_lines = headers.flat_map do |key, value|
              if value.respond_to? :each_line
                value.each_line.map { |line| "#{key}: #{line.chomp}" }
              elsif value.respond_to? :each
                buffer = []
                value.each { |line| buffer << "#{key}: #{line}" }
                buffer
              else
                "#{key}: #{value}"
              end
            end.join(CRLF)

            client.write(response_line + header_lines + CRLF)

            body.each { |chunk| client.write(chunk) }
            body.close if body.respond_to?(:close)

            client.close
          end

          client.on(:data) { |chunk| parser << chunk }
        end
      end

      # Copied from lib/reel/rack/server.rb
      # Those headers must not start with "HTTP_".
      NO_PREFIX_HEADERS=%w[CONTENT_TYPE CONTENT_LENGTH].freeze

      def convert_headers(headers)
        Hash[headers.map { |key, value|
          header = key.upcase.gsub("-", "_")

          if NO_PREFIX_HEADERS.member?(header)
            [header, value]
          else
            ["HTTP_" + header, value]
          end
        }]
      end

      # Copied from lib/puma/server.rb
      def normalize_env(env)
        if host = env["HTTP_HOST"]
          if colon = host.index(":")
            env["SERVER_NAME"] = host[0, colon]
            env["SERVER_PORT"] = host[colon+1, host.bytesize]
          else
            env["SERVER_NAME"] = host
            env["SERVER_PORT"] = default_server_port(env)
          end
        else
          env["SERVER_NAME"] = "localhost"
          env["SERVER_PORT"] = default_server_port(env)
        end
      end

      def default_server_port(env)
        env["HTTP_X_FORWARDED_PROTO"] == "https" ? 443 : 80
      end
    end
  end
end
