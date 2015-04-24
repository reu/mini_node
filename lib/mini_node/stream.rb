module MiniNode
  class Stream
    include EventEmitter

    def initialize(fd, chunk_size = 16 * 1024)
      @fd = fd
      @write_buffer = ""
      @chunk_size = chunk_size
    end

    def handle_read
      data = @fd.read_nonblock(@chunk_size)
      emit(:data, data)
    rescue EOFError, IOError
      close unless @fd.closed?
    end

    def handle_write
      write(@write_buffer) if !@write_buffer.empty?
    end

    def write(data)
      bytes_written = @fd.write_nonblock(data)
      @write_buffer = data[bytes_written..-1]
    rescue Errno::EAGAIN, Errno::EPIPE
    end

    def close
      emit(:close)
      @fd.close
    end

    def to_io
      @fd
    end

    def remote_address
      @fd.remote_address
    end

    def to_s
      "#<#{self.class}:#{@fd.fileno}>"
    end
  end
end
