require "rack/handler"

require "mini_node/reactor"
require "mini_node/rack/server"

module Rack
  module Handler
    class MiniNode
      DEFAULT_OPTIONS = {
        :Host    => "0.0.0.0",
        :Port    => 5000,
        :quiet   => false
      }

      def self.run(app, reactor, options = {})
        options = DEFAULT_OPTIONS.merge(options)

        ENV["RACK_ENV"] = options[:environment].to_s if options[:environment]

        ::MiniNode::Rack::Server.new(reactor).run(app, options)

        @reactor.start
      end
    end

    register :mini_node, MiniNode
  end
end
