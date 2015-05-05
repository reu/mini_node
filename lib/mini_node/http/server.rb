require "http/parser"

require "mini_node/event_emitter"
require "mini_node/http/headers"
require "mini_node/http/request"
require "mini_node/http/response"

module MiniNode
  module HTTP
    class Server
      include EventEmitter

      def initialize(server)
        server.on(:accept) do |client|
          parser = Http::Parser.new

          request = Request.new
          request.body = ""

          parser.on_headers_complete = proc do
            request.verb = parser.http_method
            request.path = parser.request_url
            request.headers = Headers.from_hash(parser.headers)
          end

          parser.on_body = proc do |chunk|
            request.body << chunk
          end

          parser.on_message_complete = proc do |env|
            response = Response.new(request, client)
            emit(:request, request, response)
          end

          client.on(:data) do |data|
            parser << data
          end
        end
      end
    end
  end
end
