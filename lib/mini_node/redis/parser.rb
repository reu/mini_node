module MiniNode
  module Redis
    class Parser
      CRLF = "\r\n".freeze

      def initialize
        @buffer = ""
        @bytes_to_read = nil
      end

      def <<(data)
        @buffer << data
        parse_reply
      end

      def on_reply(&callback)
        @callback = callback
      end

      private

      def parse_reply
        while (crlf = @buffer.index(CRLF)) do
          if crlf
            puts @buffer
            if @bytes_to_read && @buffer.size >= @bytes_to_read
              reply = @buffer.slice(0, crlf)
              @buffer.slice!(0, crlf + CRLF.bytesize)
              @bytes_to_read = nil
              fire_callback(reply)
            elsif @buffer =~ /\$(-?\d+)/
              reply = $1.to_i

              if reply > 0
                @bytes_to_read = reply
              else
                fire_callback
              end

              @buffer.slice!(0, crlf + CRLF.bytesize)
            elsif @buffer =~ /\+/
              @buffer.slice!(0, crlf + CRLF.bytesize)
              fire_callback
            elsif @buffer =~ /\:(\d+)/
              reply = @buffer.slice!(0, crlf + CRLF.bytesize)
              fire_callback(reply[1...-CRLF.bytesize].to_i)
            end
          end
        end
      end

      def fire_callback(data = nil)
        @callback.call(data) if @callback
      end
    end
  end
end
