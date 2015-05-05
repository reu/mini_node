require "socket"

require "mini_node/event_emitter"
require "mini_node/stream"
require "mini_node/file"
require "mini_node/server"

module MiniNode
  class Reactor
    def initialize
      @reading = []
      @writing = []
    end

    def listen(host, port)
      server = Server.new(TCPServer.new(host, port))
      monitor(server)
      server
    end

    def connect(host, port)
      stream = Stream.new(TCPSocket.new(host, port))
      monitor(stream)
      stream
    end

    def open(*args)
      stream = File.new(::File.open(*args))
      monitor(stream)
      stream
    end

    def monitor(stream)
      case stream
      when Server
        register(stream, group: @reading)
        stream.on(:accept) { |connection| monitor(connection) }
      when Stream
        register(stream, group: @reading)
        register(stream, group: @writing)
      end
    end

    def start
      loop { tick }
    end

    def stop
      @reading.each(&:close)
      @writing.each(&:close)
    end

    def tick
      readable, writeable, _ = IO.select(@reading, @writing, [])

      readable.each(&:handle_read) if readable
      writeable.each(&:handle_write) if writeable
    end

    def self.loop
      reactor = new
      yield reactor
      reactor.start
    rescue Interrupt
      reactor.stop
      raise
    end

    private

    def register(stream, group:)
      group << stream

      stream.on(:close) do
        group.delete(stream)
      end
    end
  end
end
