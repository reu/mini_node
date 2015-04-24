require "mini_node/stream"

module MiniNode
  class File < Stream
    def size
      @fd.size
    end
  end
end
