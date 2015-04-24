require "mime/types"

require "mini_node/stream"

module MiniNode
  class File < Stream
    def size
      @fd.size
    end

    def name
      ::File.basename(@fd.path)
    end

    def content_type
      MIME::Types.of(name).first
    end
  end
end
