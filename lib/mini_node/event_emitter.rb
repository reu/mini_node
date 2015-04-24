module MiniNode
  module EventEmitter
    def callbacks
      @callbacks ||= Hash.new { |hash, key| hash[key] = [] }
    end

    def on(event, &callback)
      callbacks[event] << callback
    end

    def emit(event, *args)
      callbacks[event].each do |callback|
        callback.call(*args)
      end
    end
  end
end
