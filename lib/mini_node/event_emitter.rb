module MiniNode
  module EventEmitter
    def callbacks
      @callbacks ||= Hash.new { |hash, key| hash[key] = [] }
    end

    def on(event, &callback)
      callbacks[event] << callback
    end

    def once(event, &callback)
      block = proc do |*args|
        result = callback.call(*args)
        @callbacks[event].delete(block)
        result
      end

      on(event, &block)
    end

    def emit(event, *args)
      callbacks[event].dup.each do |callback|
        callback.call(*args)
      end
    end
  end
end
