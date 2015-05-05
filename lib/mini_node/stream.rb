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
    rescue EOFError, IOError, Errno::ECONNRESET
      close unless @fd.closed?
    end

    def handle_write
      write_to_fd(@write_buffer) if !@write_buffer.empty?
    end

    def write(data)
      @write_buffer << data
      write_to_fd(@write_buffer)
    end

    def close
      @write_buffer.empty? ? close_fd : once(:drain) { close_fd }
    end

    def pipe(stream)
      on(:data) { |data| stream.write(data) }
      on(:close) { stream.close }
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

    private

    def close_fd
      emit(:close)
      @fd.close unless @fd.closed?
    end

    def write_to_fd(data)
      bytes_written = @fd.write_nonblock(data)
      @write_buffer = data[bytes_written..-1]
      emit(:drain) if @write_buffer.empty?
    rescue Errno::EAGAIN, Errno::EPIPE, Errno::ECONNRESET
    end
  end
end
