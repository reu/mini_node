require "mime/types"

require "mini_node/stream"

module MiniNode
  class File < Stream
    def initialize(*args)
      super
      @reading = false
    end

    def read
      @reading = true
    end

    def size
      @fd.size
    end

    def handle_read
      super if @reading
    end

    def pipe(*args)
      @reading = true
      super
    end

    def name
      ::File.basename(@fd.path)
    end

    def content_type
      MIME::Types.of(name).first
    end
  end
end
