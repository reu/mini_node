require "hiredis/reader"

module MiniNode
  module Redis
    class Parser
      def initialize
        @parser = Hiredis::Reader.new
      end

      def <<(data)
        @parser.feed(data)

        loop do
          reply = @parser.gets
          break unless reply
          fire_callback(reply)
        end
      end

      def on_reply(&callback)
        @callback = callback
      end

      private

      def fire_callback(data = nil)
        @callback.call(data) if @callback
      end
    end
  end
end
