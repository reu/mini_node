require "mini_node/stream"

module MiniNode
  class File < Stream
    def size
      @io.size
    end
  end
end
