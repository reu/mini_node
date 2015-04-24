require "mini_node/redis/parser"

module MiniNode
  module Redis
    class Client
      CRLF = "\r\n".freeze
      NULL_CALLBACK = Proc.new { }.freeze

      def initialize(stream)
        @stream = stream
        @callbacks = []

        @parser = Parser.new

        @parser.on_reply do |reply|
          @callbacks.shift.call(reply)
        end

        @stream.on(:data) do |data|
          @parser << data
        end
      end

      def method_missing(command, *args, &callback)
        call(command, *args)
        @callbacks << (callback || NULL_CALLBACK)
      end

      private

      def call(*args)
        args = args.map(&:to_s)

        @stream.write("*" + args.size.to_s + CRLF)

        args.each do |arg|
          @stream.write("$" + arg.size.to_s + CRLF + arg.to_s + CRLF)
        end
      end
    end
  end
end
