require "nio"

require "mini_node/reactor"

module MiniNode
  module Nio
    class Reactor < MiniNode::Reactor
      def initialize
        @selector = NIO::Selector.new
      end

      def monitor(stream)
        case stream
        when Server
          @selector.register(stream, :r)
          stream.on(:accept) { |connection| monitor(connection) }
        when Stream
          @selector.register(stream, :rw)
        end

        stream.on(:close) do
          @selector.deregister(stream)
        end
      end

      def stop
        @selector.close
      end

      def tick
        @selector.select do |monitor|
          monitor.io.handle_read if monitor.readable?
          monitor.io.handle_write if monitor.writeable?
        end
      end
    end
  end
end
