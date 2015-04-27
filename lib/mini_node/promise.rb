module MiniNode
  class Promise
    class Callback
      def initialize(promise, resolved, rejected)
        @promise = promise
        @resolved = resolved
        @rejected = rejected
      end

      def resolved(value)
        run(@resolved, value)
      end

      def rejected(reason)
        run(@rejected, reason)
      end

      private

      def run(callback, value)
        @promise.resolve(callback.call(value))
      rescue StandardError => error
        @promise.reject(error)
      end
    end

    def initialize(&block)
      @callbacks = []
      @status = :pending
      block.call(method(:resolve), method(:reject)) if block
    end

    def then(resolved = nil, rejected = nil, &callback)
      resolved ||= callback
      new_promise = Promise.new
      @callbacks << Callback.new(new_promise, resolved, rejected)
      new_promise
    end

    def pending?
      @status == :pending
    end

    def resolved?
      @status == :resolved
    end

    def rejected?
      @status == :rejected
    end

    def resolve(value)
      @value = value
      @status = :resolved
      fire_callbacks
    end

    def reject(reason)
      @reason = reason
      @status = :rejected
      fire_callbacks
    end

    private

    def fire_callbacks
      @callbacks.each do |callback|
        resolved? ? callback.resolved(@value) : callback.rejected(@value)
      end
    end
  end
end
