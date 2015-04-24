module MiniNode
  class Stream
    include EventEmitter

    def initialize(io, chunk_size = 16 * 1024)
      @io = io
      @write_buffer = ""
      @chunk_size = chunk_size
    end

    def handle_read
      data = @io.read_nonblock(@chunk_size)
      emit(:data, data)
    rescue EOFError, IOError
      close unless @io.closed?
    end

    def handle_write
      write(@write_buffer) if !@write_buffer.empty?
    end

    def write(data)
      bytes_written = @io.write_nonblock(data)
      @write_buffer = data[bytes_written..-1]
    rescue Errno::EAGAIN, Errno::EPIPE
    end

    def close
      emit(:close)
      @io.close
    end

    def to_io
      @io
    end

    def remote_address
      @io.remote_address
    end

    def to_s
      "#<#{self.class}:#{@io.fileno}>"
    end
  end
end
